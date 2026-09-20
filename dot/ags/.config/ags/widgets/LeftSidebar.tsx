import { createBinding, createState } from "ags"
import app from "ags/gtk4/app"
import { Gtk } from "ags/gtk4"
import { readFile } from "ags/file"
import { execAsync } from "ags/process"
import { interval } from "ags/time"
import AstalBattery from "gi://AstalBattery"
import Gio from "gi://Gio"
import GLib from "gi://GLib"
import {
  cpuUsage,
  diskRates,
  formatRate,
  memoryUsage,
  parseCpuSample,
  parseDiskSample,
  type CpuSample,
  type DiskSample,
} from "../lib/hardware"

export type PanelContent = {
  widget: Gtk.Widget
  start: () => void
  stop: () => void
}

type Telemetry = {
  cpuTemp: string
  cpuUsage: string
  cpuFreq: string
  cpuPolicy: string
  cpuFan: string
  gpuFan: string
  igpuTemp: string
  igpuUsage: string
  igpuClock: string
  apuPower: string
  dgpuTemp: string
  dgpuUsage: string
  dgpuMemory: string
  dgpuPower: string
  memory: string
  diskRead: string
  diskWrite: string
  nvmeTemp: string
  dimmTemp: string
  batteryHealth: string
  batteryVoltage: string
  batteryCycles: string
}

const unavailable: Telemetry = {
  cpuTemp: "—",
  cpuUsage: "—",
  cpuFreq: "—",
  cpuPolicy: "Unavailable",
  cpuFan: "—",
  gpuFan: "—",
  igpuTemp: "—",
  igpuUsage: "—",
  igpuClock: "—",
  apuPower: "—",
  dgpuTemp: "—",
  dgpuUsage: "—",
  dgpuMemory: "—",
  dgpuPower: "—",
  memory: "—",
  diskRead: "—",
  diskWrite: "—",
  nvmeTemp: "—",
  dimmTemp: "—",
  batteryHealth: "—",
  batteryVoltage: "—",
  batteryCycles: "—",
}

function chip(data: Record<string, any>, prefix: string) {
  return Object.entries(data).find(([name]) => name.startsWith(prefix))?.[1]
}

function sensorMaximum(data: Record<string, any>, prefix: string) {
  const values = Object.entries(data)
    .filter(([name]) => name.startsWith(prefix))
    .flatMap(([, entries]) => Object.values(entries as Record<string, any>))
    .map((entry) => (entry as Record<string, any>)?.temp1_input)
    .filter((value): value is number => typeof value === "number")
  return values.length ? Math.max(...values) : null
}

function readText(path: string) {
  try {
    return readFile(path).trim()
  } catch {
    return ""
  }
}

function readNumber(path: string) {
  return Number(readText(path)) || 0
}

function amdGpuBusy() {
  for (let index = 0; index < 4; index += 1) {
    const root = `/sys/class/drm/card${index}/device`
    if (readText(`${root}/vendor`) === "0x1002") {
      return readText(`${root}/gpu_busy_percent`)
    }
  }
  return ""
}

function formatDuration(seconds: number) {
  if (!seconds) return "—"
  const hours = Math.floor(seconds / 3600)
  const minutes = Math.round((seconds % 3600) / 60)
  return hours ? `${hours}h ${minutes}m` : `${minutes}m`
}

function batteryDetails() {
  for (const name of ["BAT0", "BAT1"]) {
    const root = `/sys/class/power_supply/${name}`
    const full = readNumber(`${root}/charge_full`)
    const design = readNumber(`${root}/charge_full_design`)
    if (!full || !design) continue
    const voltage = readNumber(`${root}/voltage_now`) / 1_000_000
    const cycles = readText(`${root}/cycle_count`)
    return {
      health: `${Math.round((full / design) * 100)}%`,
      voltage: voltage ? `${voltage.toFixed(1)} V` : "—",
      cycles: cycles || "—",
    }
  }
  return { health: "—", voltage: "—", cycles: "—" }
}

export default function LeftSidebar(): PanelContent {
  const battery = AstalBattery.get_default()
  const [telemetry, setTelemetry] = createState(unavailable)
  const [profile, setProfile] = createState("Unavailable")
  const [fanCurve, setFanCurve] = createState("Unavailable")
  const [chargeLimit, setChargeLimit] = createState("—")
  const [graphicsMode, setGraphicsMode] = createState("Unavailable")
  const [graphicsState, setGraphicsState] = createState("Unavailable")
  const [graphicsPending, setGraphicsPending] = createState("No action required")
  const [selectedMode, setSelectedMode] = createState("")
  const [brightness, setBrightness] = createState("—")
  const [keyboard, setKeyboard] = createState("Unavailable")
  const [overdrive, setOverdrive] = createState("Unavailable")
  const [message, setMessage] = createState("")
  const [busy, setBusy] = createState(false)
  let sensorTimer: ReturnType<typeof interval> | null = null
  let stateTimer: ReturnType<typeof interval> | null = null
  let previousCpu: CpuSample | null = null
  let previousDisk: DiskSample | null = null
  let previousSampleTime = 0

  const percentage = createBinding(battery, "percentage")(
    (value) => `${Math.round(value * 100)}%`,
  )
  const power = createBinding(battery, "energyRate")(
    (value) => `${Math.abs(value).toFixed(1)} W`,
  )
  const batteryState = createBinding(battery, "state")((state) =>
    ["Unknown", "Charging", "Discharging", "Empty", "Full", "Waiting", "Waiting"][state] ??
      "Unknown",
  )
  const estimate = createBinding(battery, "updateTime")(() => {
    const seconds = Number(battery.charging ? battery.timeToFull : battery.timeToEmpty)
    if (seconds) return `${formatDuration(seconds)} remaining`
    return battery.state === 4 ? "fully charged" : "estimating"
  })

  async function refreshTelemetry() {
    try {
      const now = GLib.get_monotonic_time() / 1_000_000
      const data = JSON.parse(await execAsync(["sensors", "-j"])) as Record<string, any>
      const cpu = chip(data, "k10temp-")?.Tctl?.temp1_input
      const gpu = chip(data, "amdgpu-")
      const fans = chip(data, "asus-")
      const cpuSample = parseCpuSample(readFile("/proc/stat"))
      const diskSample = parseDiskSample(readFile("/proc/diskstats"))
      const rates = diskRates(previousDisk, diskSample, now - previousSampleTime)
      const memory = memoryUsage(readFile("/proc/meminfo"))
      const batteryInfo = batteryDetails()
      let dgpu = ["—", "—", "—", "—", "—"]

      if (graphicsState.peek().toLocaleLowerCase().includes("active")) {
        try {
          dgpu = (await execAsync([
            "nvidia-smi",
            "--query-gpu=temperature.gpu,utilization.gpu,memory.used,memory.total,power.draw",
            "--format=csv,noheader,nounits",
          ])).split(",").map((value) => value.trim())
        } catch {
          // A Hybrid-mode dGPU may sleep between the status check and this query.
        }
      }

      const governor = readText("/sys/devices/system/cpu/cpufreq/policy0/scaling_governor")
      const preference = readText(
        "/sys/devices/system/cpu/cpufreq/policy0/energy_performance_preference",
      )
      const boost = readText("/sys/devices/system/cpu/cpufreq/boost")
      const frequency = readNumber(
        "/sys/devices/system/cpu/cpufreq/policy0/scaling_cur_freq",
      ) / 1_000_000
      const igpuUsage = amdGpuBusy()
      const nvme = sensorMaximum(data, "nvme-")
      const dimm = sensorMaximum(data, "spd5118-")

      setTelemetry({
        cpuTemp: typeof cpu === "number" ? `${Math.round(cpu)}°C` : "—",
        cpuUsage: `${Math.round(cpuUsage(previousCpu, cpuSample))}%`,
        cpuFreq: frequency ? `${frequency.toFixed(2)} GHz` : "—",
        cpuPolicy: [governor, preference, boost === "1" ? "boost" : "boost off"]
          .filter(Boolean)
          .join(" · ") || "Unavailable",
        cpuFan:
          typeof fans?.cpu_fan?.fan1_input === "number"
            ? `${Math.round(fans.cpu_fan.fan1_input)} RPM`
            : "—",
        gpuFan:
          typeof fans?.gpu_fan?.fan2_input === "number"
            ? `${Math.round(fans.gpu_fan.fan2_input)} RPM`
            : "—",
        igpuTemp:
          typeof gpu?.edge?.temp1_input === "number"
            ? `${Math.round(gpu.edge.temp1_input)}°C`
            : "—",
        igpuUsage: igpuUsage ? `${igpuUsage}%` : "—",
        igpuClock:
          typeof gpu?.sclk?.freq1_input === "number"
            ? `${(gpu.sclk.freq1_input / 1_000_000_000).toFixed(2)} GHz`
            : "—",
        apuPower:
          typeof gpu?.PPT?.power1_average === "number"
            ? `${gpu.PPT.power1_average.toFixed(1)} W`
            : "—",
        dgpuTemp: dgpu[0] === "—" ? "—" : `${dgpu[0]}°C`,
        dgpuUsage: dgpu[1] === "—" ? "—" : `${dgpu[1]}%`,
        dgpuMemory: dgpu[2] === "—" ? "—" : `${dgpu[2]} / ${dgpu[3]} MiB`,
        dgpuPower: dgpu[4] === "—" ? "—" : `${Number(dgpu[4]).toFixed(1)} W`,
        memory: memory.total
          ? `${((memory.used / memory.total) * 100).toFixed(0)}% · ${(memory.used / 1024 / 1024).toFixed(1)} GiB`
          : "—",
        diskRead: formatRate(rates.read),
        diskWrite: formatRate(rates.write),
        nvmeTemp: nvme === null ? "—" : `${Math.round(nvme)}°C`,
        dimmTemp: dimm === null ? "—" : `${Math.round(dimm)}°C`,
        batteryHealth: batteryInfo.health,
        batteryVoltage: batteryInfo.voltage,
        batteryCycles: batteryInfo.cycles,
      })
      previousCpu = cpuSample
      previousDisk = diskSample
      previousSampleTime = now
    } catch {
      setTelemetry(unavailable)
    }
  }

  async function refreshState() {
    const results = await Promise.allSettled([
      execAsync(["asusctl", "profile", "get"]),
      execAsync(["asusctl", "battery", "info"]),
      execAsync(["asusctl", "fan-curve", "--get-enabled"]),
      execAsync(["asusctl", "leds", "get"]),
      execAsync(["asusctl", "armoury", "get", "panel_overdrive"]),
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
    const curves = value(2)

    setProfile(value(0).match(/Active profile:\s*(\w+)/)?.[1] ?? "Unavailable")
    setChargeLimit(value(1).match(/(\d+)%/)?.[1] ?? "—")
    setFanCurve(
      !curves
        ? "Unavailable"
        : /enabled:\s*true/.test(curves)
        ? [
            /CPU: enabled:\s*true/.test(curves) ? "CPU custom" : "",
            /GPU: enabled:\s*true/.test(curves) ? "GPU custom" : "",
          ].filter(Boolean).join(" · ")
        : "Firmware curves",
    )
    setKeyboard(value(3).match(/brightness:\s*(\w+)/i)?.[1] ?? "Unavailable")
    const overdriveValue = value(4).match(/\((\d+)\)/)?.[1]
    setOverdrive(overdriveValue ? (overdriveValue === "1" ? "On" : "Off") : "Unavailable")
    setGraphicsMode(value(5) || "Unavailable")
    setGraphicsState(value(6) || "Unavailable")
    setGraphicsPending(
      [value(7), value(8)].filter((item) => item && item !== "Unknown").join(" · ") ||
        "No action required",
    )
    setBrightness(value(9).split(",")[3] || "—")
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

  function launchCurves() {
    try {
      Gio.Subprocess.new(["rog-control-center"], Gio.SubprocessFlags.NONE)
    } catch (error) {
      setMessage(`Unavailable: ${error instanceof Error ? error.message : String(error)}`)
    }
  }

  function start() {
    stop()
    previousCpu = null
    previousDisk = null
    previousSampleTime = 0
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
          <label class="sidebar-title" label="Machine dashboard" xalign={0} />
        </box>
        <button tooltipText="Close" onClicked={() => app.toggle_window("sidebar-left")}>
          <label label="󰅖" />
        </button>
      </box>

      <scrolledwindow vexpand hscrollbarPolicy={Gtk.PolicyType.NEVER}>
        <box class="sidebar-scroll laptop-dashboard-scroll" orientation={Gtk.Orientation.VERTICAL}>
          <box class="dashboard-columns" homogeneous spacing={10}>
            <box class="dashboard-column" orientation={Gtk.Orientation.VERTICAL} spacing={10}>
              <box class="panel-section" orientation={Gtk.Orientation.VERTICAL} spacing={7}>
                <box>
                  <label class="section-title" label="Battery" xalign={0} hexpand />
                  <label class="section-state" label={batteryState} />
                </box>
                <box class="metric-strip" homogeneous>
                  <box orientation={Gtk.Orientation.VERTICAL}>
                    <label class="metric-value" label={percentage} />
                    <label class="metric-label" label={estimate} />
                  </box>
                  <box orientation={Gtk.Orientation.VERTICAL}>
                    <label class="metric-value" label={power} />
                    <label class="metric-label" label="charge / drain" />
                  </box>
                  <box orientation={Gtk.Orientation.VERTICAL}>
                    <label class="metric-value" label={telemetry((value) => value.batteryHealth)} />
                    <label class="metric-label" label={chargeLimit((value) => `limit ${value}%`)} />
                  </box>
                </box>
                <label
                  class="detail-line"
                  label={telemetry((value) => `${value.batteryVoltage} · ${value.batteryCycles} cycles`)}
                  xalign={0}
                />
                <box class="button-row compact" spacing={5}>
                  {["60", "80"].map((limit) => (
                    <button
                      hexpand
                      class={chargeLimit((value) => (value === limit ? "active" : ""))}
                      sensitive={busy((value) => !value)}
                      onClicked={() => void action(
                        ["asusctl", "battery", "limit", limit],
                        `${limit}% care enabled`,
                      )}
                    >
                      <label label={`${limit}%`} />
                    </button>
                  ))}
                  <button
                    hexpand
                    sensitive={busy((value) => !value)}
                    onClicked={() => void action(
                      ["asusctl", "battery", "oneshot"],
                      "Full charge enabled once",
                    )}
                  >
                    <label label="Full once" />
                  </button>
                </box>
              </box>

              <box class="panel-section" orientation={Gtk.Orientation.VERTICAL} spacing={7}>
                <box>
                  <label class="section-title" label="CPU & cooling" xalign={0} hexpand />
                  <label class="section-state" label={profile} />
                </box>
                <box class="metric-strip" homogeneous>
                  <box orientation={Gtk.Orientation.VERTICAL}>
                    <label class="metric-value" label={telemetry((value) => value.cpuTemp)} />
                    <label class="metric-label" label="CPU temp" />
                  </box>
                  <box orientation={Gtk.Orientation.VERTICAL}>
                    <label class="metric-value" label={telemetry((value) => value.cpuUsage)} />
                    <label class="metric-label" label="CPU load" />
                  </box>
                  <box orientation={Gtk.Orientation.VERTICAL}>
                    <label class="metric-value" label={telemetry((value) => value.cpuFreq)} />
                    <label class="metric-label" label="policy 0" />
                  </box>
                </box>
                <box class="metric-strip" homogeneous>
                  <box orientation={Gtk.Orientation.VERTICAL}>
                    <label class="metric-value" label={telemetry((value) => value.cpuFan)} />
                    <label class="metric-label" label="CPU fan" />
                  </box>
                  <box orientation={Gtk.Orientation.VERTICAL}>
                    <label class="metric-value" label={telemetry((value) => value.gpuFan)} />
                    <label class="metric-label" label="GPU fan" />
                  </box>
                  <box orientation={Gtk.Orientation.VERTICAL}>
                    <label class="metric-value" label={fanCurve} />
                    <label class="metric-label" label="fan curve" />
                  </box>
                </box>
                <label class="detail-line" label={telemetry((value) => value.cpuPolicy)} xalign={0} />
                <box class="button-row compact" spacing={5}>
                  {["Quiet", "Balanced", "Performance"].map((name) => (
                    <button
                      hexpand
                      class={profile((value) => (value === name ? "active" : ""))}
                      sensitive={busy((value) => !value)}
                      onClicked={() => void action(
                        ["asusctl", "profile", "set", name],
                        `${name} profile enabled`,
                      )}
                    >
                      <label label={name} />
                    </button>
                  ))}
                </box>
                <button onClicked={launchCurves}>
                  <label label="Advanced fan curves…" />
                </button>
              </box>

              <box class="panel-section" orientation={Gtk.Orientation.VERTICAL} spacing={7}>
                <label class="section-title" label="Memory & storage" xalign={0} />
                <box class="metric-strip" homogeneous>
                  <box orientation={Gtk.Orientation.VERTICAL}>
                    <label class="metric-value" label={telemetry((value) => value.memory)} />
                    <label class="metric-label" label="memory used" />
                  </box>
                  <box orientation={Gtk.Orientation.VERTICAL}>
                    <label class="metric-value" label={telemetry((value) => value.diskRead)} />
                    <label class="metric-label" label="NVMe read" />
                  </box>
                  <box orientation={Gtk.Orientation.VERTICAL}>
                    <label class="metric-value" label={telemetry((value) => value.diskWrite)} />
                    <label class="metric-label" label="NVMe write" />
                  </box>
                </box>
                <label
                  class="detail-line"
                  label={telemetry((value) => `NVMe ${value.nvmeTemp} · DIMM ${value.dimmTemp}`)}
                  xalign={0}
                />
              </box>
            </box>

            <box class="dashboard-column" orientation={Gtk.Orientation.VERTICAL} spacing={10}>
              <box class="panel-section" orientation={Gtk.Orientation.VERTICAL} spacing={7}>
                <box>
                  <label class="section-title" label="Graphics" xalign={0} hexpand />
                  <label class="section-state" label={graphicsMode} />
                </box>
                <box class="metric-strip" homogeneous>
                  <box orientation={Gtk.Orientation.VERTICAL}>
                    <label class="metric-value" label={telemetry((value) => value.igpuTemp)} />
                    <label class="metric-label" label="iGPU temp" />
                  </box>
                  <box orientation={Gtk.Orientation.VERTICAL}>
                    <label class="metric-value" label={telemetry((value) => value.igpuUsage)} />
                    <label class="metric-label" label="iGPU load" />
                  </box>
                  <box orientation={Gtk.Orientation.VERTICAL}>
                    <label class="metric-value" label={telemetry((value) => value.igpuClock)} />
                    <label class="metric-label" label="iGPU clock" />
                  </box>
                </box>
                <box class="metric-strip" homogeneous>
                  <box orientation={Gtk.Orientation.VERTICAL}>
                    <label class="metric-value" label={telemetry((value) => value.apuPower)} />
                    <label class="metric-label" label="APU PPT" />
                  </box>
                  <box orientation={Gtk.Orientation.VERTICAL}>
                    <label class="metric-value" label={telemetry((value) => value.dgpuTemp)} />
                    <label class="metric-label" label="dGPU temp" />
                  </box>
                  <box orientation={Gtk.Orientation.VERTICAL}>
                    <label class="metric-value" label={telemetry((value) => value.dgpuUsage)} />
                    <label class="metric-label" label="dGPU load" />
                  </box>
                </box>
                <box class="metric-strip" homogeneous>
                  <box orientation={Gtk.Orientation.VERTICAL}>
                    <label class="metric-value" label={telemetry((value) => value.dgpuMemory)} />
                    <label class="metric-label" label="dGPU VRAM" />
                  </box>
                  <box orientation={Gtk.Orientation.VERTICAL}>
                    <label class="metric-value" label={telemetry((value) => value.dgpuPower)} />
                    <label class="metric-label" label="dGPU power" />
                  </box>
                  <box orientation={Gtk.Orientation.VERTICAL}>
                    <label class="metric-value" label={graphicsState} />
                    <label class="metric-label" label="dGPU state" />
                  </box>
                </box>
                <box class="button-row compact" spacing={5}>
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
                  spacing={5}
                >
                  <label
                    label={selectedMode(
                      (value) => `${value} may require logout or reboot. Apply without ending this session?`,
                    )}
                    wrap
                    xalign={0}
                  />
                  <box class="button-row compact" spacing={5}>
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
                        if (mode) void action(
                          ["supergfxctl", "--mode", mode],
                          `${mode} requested`,
                        )
                      }}
                    >
                      <label label="Apply mode" />
                    </button>
                  </box>
                </box>
                <label class="panel-note" label={graphicsPending} wrap xalign={0} />
              </box>

              <box class="panel-section" orientation={Gtk.Orientation.VERTICAL} spacing={7}>
                <box>
                  <label class="section-title" label="Display" xalign={0} hexpand />
                  <label class="section-state" label={brightness} />
                </box>
                <box class="button-row compact" spacing={5}>
                  {[
                    ["− 5%", "5%-", "Brightness lowered"],
                    ["+ 5%", "+5%", "Brightness raised"],
                  ].map(([label, delta, success]) => (
                    <button
                      hexpand
                      sensitive={busy((value) => !value)}
                      onClicked={() => void action(
                        [
                          "brightnessctl",
                          "--class=backlight",
                          "--device=nvidia_wmi_ec_backlight",
                          "--min-value=1",
                          "set",
                          delta,
                        ],
                        success,
                      )}
                    >
                      <label label={label} />
                    </button>
                  ))}
                </box>
                <box>
                  <label class="section-title" label="Keyboard light" xalign={0} hexpand />
                  <label class="section-state" label={keyboard} />
                </box>
                <box class="button-row compact" spacing={5}>
                  {["Off", "Low", "Med", "High"].map((level) => (
                    <button
                      hexpand
                      class={keyboard((value) => (
                        value.toLocaleLowerCase() === level.toLocaleLowerCase() ? "active" : ""
                      ))}
                      sensitive={busy((value) => !value)}
                      onClicked={() => void action(
                        ["asusctl", "leds", "set", level.toLocaleLowerCase()],
                        `${level} keyboard light enabled`,
                      )}
                    >
                      <label label={level} />
                    </button>
                  ))}
                </box>
                <box>
                  <box hexpand orientation={Gtk.Orientation.VERTICAL}>
                    <label class="section-title" label="Panel overdrive" xalign={0} />
                    <label class="panel-note" label="Faster panel response; uses more power." xalign={0} />
                  </box>
                  <button
                    class={overdrive((value) => (value === "On" ? "active" : ""))}
                    sensitive={busy((value) => !value)}
                    onClicked={() => void action(
                      [
                        "asusctl",
                        "armoury",
                        "set",
                        "panel_overdrive",
                        overdrive.peek() === "On" ? "0" : "1",
                      ],
                      "Panel overdrive updated",
                    )}
                  >
                    <label label={overdrive} />
                  </button>
                </box>
              </box>
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
