import { execAsync } from "ags/process"
import AstalBattery from "gi://AstalBattery"
import GLib from "gi://GLib"

const lowThreshold = 0.10
const lowResetThreshold = 0.12
const cycleWindowMs = 15_000
const cycleCooldownMs = 60_000

export type BatteryAlert = "low" | "power-cycle"

export type BatteryAlertState = {
  acOnline: boolean | null
  lowNotified: boolean
  powerChanges: number[]
  lastPowerWarning: number | null
}

export function initialBatteryAlertState(): BatteryAlertState {
  return {
    acOnline: null,
    lowNotified: false,
    powerChanges: [],
    lastPowerWarning: null,
  }
}

export function batteryAlerts(
  previous: BatteryAlertState,
  percentage: number,
  acOnline: boolean,
  now: number,
) {
  const alerts: BatteryAlert[] = []
  let lowNotified = previous.lowNotified
  let powerChanges = previous.powerChanges.filter((time) => now - time <= cycleWindowMs)
  let lastPowerWarning = previous.lastPowerWarning

  if (percentage >= lowResetThreshold) lowNotified = false
  if (percentage <= lowThreshold && !acOnline && !lowNotified) {
    alerts.push("low")
    lowNotified = true
  }

  if (previous.acOnline !== null && previous.acOnline !== acOnline) {
    powerChanges = [...powerChanges, now]
  }
  if (
    powerChanges.length >= 2 &&
    (lastPowerWarning === null || now - lastPowerWarning >= cycleCooldownMs)
  ) {
    alerts.push("power-cycle")
    powerChanges = []
    lastPowerWarning = now
  }

  return {
    alerts,
    state: { acOnline, lowNotified, powerChanges, lastPowerWarning },
  }
}

function notify(alert: BatteryAlert) {
  const message = alert === "low"
    ? ["Battery below 10%", "Connect the charger soon."]
    : [
        "Power connection is unstable",
        "AC power changed repeatedly within 15 seconds. Reseat the charger and check the cable.",
      ]
  void execAsync([
    "notify-send",
    "--urgency=critical",
    "--app-name=MamboDot",
    ...message,
  ]).catch(() => {})
}

export function startBatteryMonitor() {
  const battery = AstalBattery.get_default()!
  const power = AstalBattery.UPower.new()
  let state = initialBatteryAlertState()

  function sample() {
    if (!battery.isPresent) return
    const result = batteryAlerts(
      state,
      battery.percentage,
      !power.onBattery,
      GLib.get_monotonic_time() / 1000,
    )
    state = result.state
    result.alerts.forEach(notify)
  }

  const signals = [
    battery.connect("notify::percentage", sample),
    power.connect("notify::on-battery", sample),
  ]
  sample()

  return () => {
    battery.disconnect(signals[0])
    power.disconnect(signals[1])
  }
}

if (GLib.getenv("MAMBODOT_TEST") === "1") {
  let state = initialBatteryAlertState()
  let result = batteryAlerts(state, 0.09, false, 0)
  if (result.alerts.join() !== "low") throw new Error("low-battery alert did not fire")
  state = result.state
  result = batteryAlerts(state, 0.08, false, 1000)
  if (result.alerts.length) throw new Error("low-battery alert repeated")
  state = batteryAlerts(result.state, 0.13, false, 2000).state
  result = batteryAlerts(state, 0.10, false, 3000)
  if (result.alerts.join() !== "low") throw new Error("low-battery alert did not re-arm")

  state = initialBatteryAlertState()
  state = batteryAlerts(state, 0.50, false, 0).state
  state = batteryAlerts(state, 0.50, true, 5000).state
  result = batteryAlerts(state, 0.50, false, 10_000)
  if (result.alerts.join() !== "power-cycle") {
    throw new Error("rapid power-cycle alert did not fire")
  }
  result = batteryAlerts(result.state, 0.50, true, 12_000)
  if (result.alerts.length) throw new Error("power-cycle cooldown failed")
}
