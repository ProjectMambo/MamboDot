import { createBinding, createState } from "ags"
import app from "ags/gtk4/app"
import { Gtk } from "ags/gtk4"
import { readFile } from "ags/file"
import { execAsync } from "ags/process"
import { interval } from "ags/time"
import AstalBattery from "gi://AstalBattery"

export type PanelContent = {
  widget: Gtk.Widget
  start: () => void
  stop: () => void
}

type Telemetry = {
  cpu: string
  gpu: string
  cpuFan: string
  gpuFan: string
  gpuPower: string
}

const unavailable: Telemetry = {
  cpu: "—",
  gpu: "—",
  cpuFan: "—",
  gpuFan: "—",
  gpuPower: "—",
}

function chip(data: Record<string, any>, prefix: string) {
  return Object.entries(data).find(([name]) => name.startsWith(prefix))?.[1]
}

function formatDuration(seconds: number) {
  if (!seconds) return "Calculating"
  const hours = Math.floor(seconds / 3600)
  const minutes = Math.round((seconds % 3600) / 60)
  return hours ? `${hours}h ${minutes}m` : `${minutes}m`
}

function batteryHealth() {
  for (const name of ["BAT0", "BAT1"]) {
    try {
      const root = `/sys/class/power_supply/${name}`
      const full = Number(readFile(`${root}/charge_full`))
      const design = Number(readFile(`${root}/charge_full_design`))
      if (full && design) return `${Math.round((full / design) * 100)}% health`
    } catch {
      // Try the other conventional battery name.
    }
  }
  return "— health"
}

export default function LeftSidebar(): PanelContent {
  const battery = AstalBattery.get_default()
  const [telemetry, setTelemetry] = createState(unavailable)
  const [profile, setProfile] = createState("Unavailable")
  const [chargeLimit, setChargeLimit] = createState("—")
  const [graphicsMode, setGraphicsMode] = createState("Unavailable")
  const [graphicsState, setGraphicsState] = createState("Unavailable")
  const [graphicsPending, setGraphicsPending] = createState("No action required")
  const [selectedMode, setSelectedMode] = createState("")
  const [brightness, setBrightness] = createState("—")
  const [message, setMessage] = createState("")
  const [busy, setBusy] = createState(false)
  let sensorTimer: ReturnType<typeof interval> | null = null
  let stateTimer: ReturnType<typeof interval> | null = null

  const percentage = createBinding(battery, "percentage")(
    (value) => `${Math.round(value * 100)}%`,
  )
  const health = batteryHealth()
  const power = createBinding(battery, "energyRate")(
    (value) => `${Math.abs(value).toFixed(1)} W`,
  )
  const batteryState = createBinding(battery, "charging")((charging) =>
    charging ? "Charging" : "On battery",
  )
  const estimate = createBinding(battery, "updateTime")(() =>
    formatDuration(Number(battery.charging ? battery.timeToFull : battery.timeToEmpty)),
  )

  async function refreshTelemetry() {
    try {
      const data = JSON.parse(await execAsync(["sensors", "-j"])) as Record<string, any>
      const cpu = chip(data, "k10temp-")?.Tctl?.temp1_input
      const gpu = chip(data, "amdgpu-")
      const fans = chip(data, "asus-")

      setTelemetry({
        cpu: typeof cpu === "number" ? `${Math.round(cpu)}°C` : "—",
        gpu: typeof gpu?.edge?.temp1_input === "number" ? `${Math.round(gpu.edge.temp1_input)}°C` : "—",
        cpuFan:
          typeof fans?.cpu_fan?.fan1_input === "number"
            ? `${Math.round(fans.cpu_fan.fan1_input)} RPM`
            : "—",
        gpuFan:
          typeof fans?.gpu_fan?.fan2_input === "number"
            ? `${Math.round(fans.gpu_fan.fan2_input)} RPM`
            : "—",
        gpuPower:
          typeof gpu?.PPT?.power1_average === "number"
            ? `${gpu.PPT.power1_average.toFixed(1)} W`
            : "—",
      })
    } catch {
      setTelemetry(unavailable)
    }
  }

  async function refreshState() {
    const results = await Promise.allSettled([
      execAsync(["asusctl", "profile", "get"]),
      execAsync(["asusctl", "battery", "info"]),
      execAsync(["supergfxctl", "--get"]),
      execAsync(["supergfxctl", "--status"]),
      execAsync(["supergfxctl", "--pend-action"]),
      execAsync(["supergfxctl", "--pend-mode"]),
      execAsync([
        "brightnessctl",
        "--machine-readable",
        "--class=backlight",
        "--device=nvidia_wmi_ec_backlight",
      ]),
    ])
    const value = (index: number) =>
      results[index].status === "fulfilled" ? results[index].value : ""

    setProfile(value(0).match(/Active profile:\s*(\w+)/)?.[1] ?? "Unavailable")
    setChargeLimit(value(1).match(/(\d+)%/)?.[1] ?? "—")
    setGraphicsMode(value(2) || "Unavailable")
    setGraphicsState(value(3) || "Unavailable")
    setGraphicsPending(
      [value(4), value(5)].filter((item) => item && item !== "Unknown").join(" · ") ||
        "No action required",
    )
    setBrightness(value(6).split(",")[3] || "—")
  }

  async function action(command: string[], success: string) {
    setBusy(true)
    setMessage("")
    try {
      const output = await execAsync(command)
      setMessage(output || success)
      await refreshState()
    } catch (error) {
      setMessage(`Unavailable: ${error instanceof Error ? error.message : String(error)}`)
    } finally {
      setBusy(false)
    }
  }

  function start() {
    stop()
    sensorTimer = interval(3000, () => void refreshTelemetry())
    stateTimer = interval(10000, () => void refreshState())
  }

  function stop() {
    sensorTimer?.cancel()
    stateTimer?.cancel()
    sensorTimer = null
    stateTimer = null
  }

  const widget = (
    <box class="sidebar-body" orientation={Gtk.Orientation.VERTICAL}>
      <box class="sidebar-header">
        <box hexpand orientation={Gtk.Orientation.VERTICAL}>
          <label class="eyebrow" label="LAPTOP" xalign={0} />
          <label class="sidebar-title" label="Machine control" xalign={0} />
        </box>
        <button tooltipText="Close" onClicked={() => app.toggle_window("sidebar-left")}>
          <label label="󰅖" />
        </button>
      </box>

      <scrolledwindow vexpand hscrollbarPolicy={Gtk.PolicyType.NEVER}>
        <box class="sidebar-scroll" orientation={Gtk.Orientation.VERTICAL} spacing={12}>
          <box class="panel-section" orientation={Gtk.Orientation.VERTICAL} spacing={8}>
            <label class="section-title" label="Battery" xalign={0} />
            <box class="metric-strip" homogeneous>
              <box orientation={Gtk.Orientation.VERTICAL}>
                <label class="metric-value" label={percentage} />
                <label class="metric-label" label={batteryState} />
              </box>
              <box orientation={Gtk.Orientation.VERTICAL}>
                <label class="metric-value" label={power} />
                <label class="metric-label" label={estimate} />
              </box>
              <box orientation={Gtk.Orientation.VERTICAL}>
                <label class="metric-value" label={health} />
                <label class="metric-label" label={chargeLimit((value) => `Limit ${value}%`)} />
              </box>
            </box>
            <box class="button-row" spacing={6}>
              <button
                hexpand
                sensitive={busy((value) => !value)}
                onClicked={() => void action(["asusctl", "battery", "limit", "80"], "80% care enabled")}
              >
                <label label="80% care" />
              </button>
              <button
                hexpand
                sensitive={busy((value) => !value)}
                onClicked={() => void action(["asusctl", "battery", "oneshot"], "Full charge enabled once")}
              >
                <label label="Full once" />
              </button>
            </box>
          </box>

          <box class="panel-section" orientation={Gtk.Orientation.VERTICAL} spacing={8}>
            <box>
              <label class="section-title" label="Thermal" xalign={0} hexpand />
              <label class="section-state" label={profile} />
            </box>
            <box class="metric-strip" homogeneous>
              <box orientation={Gtk.Orientation.VERTICAL}>
                <label class="metric-value" label={telemetry((value) => value.cpu)} />
                <label class="metric-label" label="CPU" />
              </box>
              <box orientation={Gtk.Orientation.VERTICAL}>
                <label class="metric-value" label={telemetry((value) => value.cpuFan)} />
                <label class="metric-label" label="CPU fan" />
              </box>
              <box orientation={Gtk.Orientation.VERTICAL}>
                <label class="metric-value" label={telemetry((value) => value.gpuFan)} />
                <label class="metric-label" label="GPU fan" />
              </box>
            </box>
            <box class="button-row" spacing={6}>
              {["Quiet", "Balanced", "Performance"].map((name) => (
                <button
                  hexpand
                  class={profile((value) => (value === name ? "active" : ""))}
                  sensitive={busy((value) => !value)}
                  onClicked={() => void action(["asusctl", "profile", "set", name], `${name} profile enabled`)}
                >
                  <label label={name} />
                </button>
              ))}
            </box>
            <label
              class="panel-note"
              label="Firmware profiles control fan behavior; raw fan curves stay in ASUS tooling."
              wrap
              xalign={0}
            />
          </box>

          <box class="panel-section" orientation={Gtk.Orientation.VERTICAL} spacing={8}>
            <box>
              <label class="section-title" label="Graphics" xalign={0} hexpand />
              <label class="section-state" label={graphicsMode} />
            </box>
            <box class="metric-strip" homogeneous>
              <box orientation={Gtk.Orientation.VERTICAL}>
                <label class="metric-value" label={telemetry((value) => value.gpu)} />
                <label class="metric-label" label="iGPU" />
              </box>
              <box orientation={Gtk.Orientation.VERTICAL}>
                <label class="metric-value" label={telemetry((value) => value.gpuPower)} />
                <label class="metric-label" label="APU power" />
              </box>
              <box orientation={Gtk.Orientation.VERTICAL}>
                <label class="metric-value" label={graphicsState} />
                <label class="metric-label" label="dGPU" />
              </box>
            </box>
            <box class="button-row" spacing={6}>
              {[
                ["Integrated", "Integrated"],
                ["Hybrid", "Hybrid"],
                ["Dedicated", "AsusMuxDgpu"],
              ].map(([label, mode]) => (
                <button
                  hexpand
                  class={graphicsMode((value) => (value === mode ? "active" : ""))}
                  sensitive={busy((value) => !value)}
                  onClicked={() => setSelectedMode(mode === graphicsMode.peek() ? "" : mode)}
                >
                  <label label={label} />
                </button>
              ))}
            </box>
            <box
              class="confirm-row"
              visible={selectedMode((value) => value.length > 0)}
              orientation={Gtk.Orientation.VERTICAL}
              spacing={6}
            >
              <label
                label={selectedMode(
                  (value) => `${value} may require logout or reboot. Apply without ending this session?`,
                )}
                wrap
                xalign={0}
              />
              <box class="button-row" spacing={6}>
                <button hexpand onClicked={() => setSelectedMode("")}>
                  <label label="Cancel" />
                </button>
                <button
                  class="destructive"
                  hexpand
                  sensitive={busy((value) => !value)}
                  onClicked={() => {
                    const mode = selectedMode.peek()
                    setSelectedMode("")
                    if (mode) void action(["supergfxctl", "--mode", mode], `${mode} requested`)
                  }}
                >
                  <label label="Apply mode" />
                </button>
              </box>
            </box>
            <label class="panel-note" label={graphicsPending} wrap xalign={0} />
          </box>

          <box class="panel-section" orientation={Gtk.Orientation.VERTICAL} spacing={8}>
            <box>
              <label class="section-title" label="Display" xalign={0} hexpand />
              <label class="section-state" label={brightness} />
            </box>
            <box class="button-row" spacing={6}>
              <button
                hexpand
                sensitive={busy((value) => !value)}
                onClicked={() =>
                  void action(
                    [
                      "brightnessctl",
                      "--class=backlight",
                      "--device=nvidia_wmi_ec_backlight",
                      "--min-value=1",
                      "set",
                      "5%-",
                    ],
                    "Brightness lowered",
                  )
                }
              >
                <label label="− 5%" />
              </button>
              <button
                hexpand
                sensitive={busy((value) => !value)}
                onClicked={() =>
                  void action(
                    [
                      "brightnessctl",
                      "--class=backlight",
                      "--device=nvidia_wmi_ec_backlight",
                      "--min-value=1",
                      "set",
                      "+5%",
                    ],
                    "Brightness raised",
                  )
                }
              >
                <label label="+ 5%" />
              </button>
            </box>
          </box>

          <label
            class="action-message"
            visible={message((value) => value.length > 0)}
            label={message}
            wrap
            xalign={0}
          />
        </box>
      </scrolledwindow>
    </box>
  ) as Gtk.Widget

  return { widget, start, stop }
}
