import { For, createBinding, createState } from "ags"
import app from "ags/gtk4/app"
import { Gtk } from "ags/gtk4"
import { readFileAsync } from "ags/file"
import { execAsync } from "ags/process"
import { interval } from "ags/time"
import AstalNetwork from "gi://AstalNetwork"
import AstalWp from "gi://AstalWp"
import GLib from "gi://GLib"
import { launchScoped } from "../lib/launch"
import { parseSchedule, type ScheduleEntry } from "../lib/schedule"
import type { PanelContent } from "./LeftSidebar"
import {
  clearNotificationHistory,
  dismissAll,
  notificationHistory,
  notifd,
} from "./Notifications"

type PlannedEntry = ScheduleEntry & { state: string }

function scheduleState(entries: ScheduleEntry[]): PlannedEntry[] {
  const now = GLib.DateTime.new_now_local()
  const minute = now.get_hour() * 60 + now.get_minute()
  let foundNext = false

  return entries.map((entry) => {
    const [startHour, startMinute] = entry.start.split(":").map(Number)
    const [endHour, endMinute] = entry.end.split(":").map(Number)
    const start = startHour * 60 + startMinute
    const end = endHour * 60 + endMinute
    let state = ""

    if (minute >= start && minute < end) {
      state = "current"
    } else if (!foundNext && start > minute) {
      state = "next"
      foundNext = true
    }

    return { ...entry, state }
  })
}

export default function RightSidebar(): PanelContent {
  const network = AstalNetwork.get_default()
  const wifi = network.wifi
  const speaker = AstalWp.get_default().audio.defaultSpeaker
  const [bluetooth, setBluetooth] = createState<boolean | null>(null)
  const [schedule, setSchedule] = createState<PlannedEntry[]>([])
  const [scheduleStatus, setScheduleStatus] = createState("Loading today’s note…")
  const [message, setMessage] = createState("")
  const [busy, setBusy] = createState(false)
  let runtimeTimer: ReturnType<typeof interval> | null = null

  const volume = createBinding(speaker, "volume")
  const dnd = createBinding(notifd, "dontDisturb")
  const activeNotices = createBinding(notifd, "notifications")
  const notices = notificationHistory((items) => items.slice(0, 5))
  const volumeLabel = createBinding(speaker, "volume")(
    (value) => `${Math.round(value * 100)}%`,
  )
  const wifiLabel = wifi
    ? createBinding(wifi, "ssid")((ssid) => ssid || (wifi.enabled ? "Not connected" : "Off"))
    : "Unavailable"

  async function refreshRuntime() {
    try {
      setBluetooth(/Powered:\s+yes/.test(await execAsync(["bluetoothctl", "show"])))
    } catch {
      setBluetooth(null)
    }
  }

  async function refreshSchedule() {
    const now = GLib.DateTime.new_now_local()
    const root =
      GLib.getenv("MAMBO_NOTES_DIR") ??
      GLib.build_filenamev([GLib.get_home_dir(), "ProjectMambo", "notes"])
    const date = now.format("%F")!
    const weekPadded = now.format("%V")!
    const weekday = now.format("%u")!
    const names = [
      `${date}-W${Number(weekPadded)}-D${weekday}.md`,
      `${date}-W${weekPadded}-D${weekday}.md`,
    ]
    const path = names
      .map((name) => GLib.build_filenamev([root, "Periodic", name]))
      .find((candidate) => GLib.file_test(candidate, GLib.FileTest.EXISTS))

    if (!path) {
      setSchedule([])
      setScheduleStatus(`No daily note for ${date}`)
      return
    }

    try {
      const entries = parseSchedule(await readFileAsync(path))
      setSchedule(scheduleState(entries))
      setScheduleStatus(entries.length ? `${entries.length} blocks · ${date}` : `No schedule · ${date}`)
    } catch (error) {
      setSchedule([])
      setScheduleStatus(`Could not read today’s note: ${error instanceof Error ? error.message : String(error)}`)
    }
  }

  async function action(command: string[], success: string) {
    setBusy(true)
    setMessage("")
    try {
      const output = await execAsync(command)
      setMessage(output || success)
      await refreshRuntime()
    } catch (error) {
      setMessage(`Unavailable: ${error instanceof Error ? error.message : String(error)}`)
    } finally {
      setBusy(false)
    }
  }

  function launch(command: string[]) {
    try {
      launchScoped(command)
    } catch (error) {
      setMessage(`Unavailable: ${error instanceof Error ? error.message : String(error)}`)
    }
  }

  function start() {
    stop()
    runtimeTimer = interval(5000, () => void refreshRuntime())
    void refreshSchedule()
  }

  function stop() {
    runtimeTimer?.cancel()
    runtimeTimer = null
  }

  const widget = (
    <box class="sidebar-body" orientation={Gtk.Orientation.VERTICAL}>
      <box class="sidebar-header">
        <box hexpand orientation={Gtk.Orientation.VERTICAL}>
          <label class="eyebrow" label="DESKTOP" xalign={0} />
          <label class="sidebar-title" label="Today & controls" xalign={0} />
        </box>
        <button tooltipText="Close" onClicked={() => app.toggle_window("sidebar-right")}>
          <label label="󰅖" />
        </button>
      </box>

      <scrolledwindow vexpand hscrollbarPolicy={Gtk.PolicyType.NEVER}>
        <box class="sidebar-scroll" orientation={Gtk.Orientation.VERTICAL} spacing={12}>
          <box class="panel-section quick-controls" orientation={Gtk.Orientation.VERTICAL} spacing={8}>
            <label class="section-title" label="Quick controls" xalign={0} />
            <box class="control-grid" spacing={6}>
              <button
                hexpand
                class={wifi ? createBinding(wifi, "enabled")((value) => (value ? "active" : "")) : ""}
                sensitive={Boolean(wifi)}
                onClicked={() => {
                  if (wifi) wifi.enabled = !wifi.enabled
                }}
              >
                <box orientation={Gtk.Orientation.VERTICAL}>
                  <image iconName={wifi ? createBinding(wifi, "iconName") : "network-wireless-offline-symbolic"} />
                  <label label="Wi-Fi" />
                  <label class="control-state" label={wifiLabel} ellipsize={3} />
                </box>
              </button>
              <button
                hexpand
                class={bluetooth((value) => (value ? "active" : ""))}
                sensitive={bluetooth((value) => value !== null)}
                onClicked={() => {
                  if (!busy.peek()) {
                    void action(
                      ["bluetoothctl", "power", bluetooth.peek() ? "off" : "on"],
                      "Bluetooth updated",
                    )
                  }
                }}
              >
                <box orientation={Gtk.Orientation.VERTICAL}>
                  <image iconName="bluetooth-active-symbolic" />
                  <label label="Bluetooth" />
                  <label
                    class="control-state"
                    label={bluetooth((value) => (value === null ? "Unavailable" : value ? "On" : "Off"))}
                  />
                </box>
              </button>
              <button
                hexpand
                class={dnd((value) => (value ? "active" : ""))}
                onClicked={() => (notifd.dontDisturb = !notifd.dontDisturb)}
              >
                <box orientation={Gtk.Orientation.VERTICAL}>
                  <image iconName="notifications-disabled-symbolic" />
                  <label label="Do not disturb" />
                  <label class="control-state" label={dnd((value) => (value ? "On" : "Off"))} />
                </box>
              </button>
            </box>
            <box class="button-row" spacing={6}>
              <button hexpand onClicked={() => launch(["nm-connection-editor"])}>
                <label label="Networks" />
              </button>
              <button hexpand onClicked={() => launch(["blueman-manager"])}>
                <label label="Devices" />
              </button>
            </box>
          </box>

          <box class="panel-section" orientation={Gtk.Orientation.VERTICAL} spacing={8}>
            <box>
              <label class="section-title" label="Audio" xalign={0} hexpand />
              <label class="section-state" label={volumeLabel} />
            </box>
            <box spacing={8}>
              <button
                class={createBinding(speaker, "mute")((value) => (value ? "active destructive" : ""))}
                tooltipText="Toggle mute"
                onClicked={() => (speaker.mute = !speaker.mute)}
              >
                <image iconName={createBinding(speaker, "volumeIcon")} />
              </button>
              <slider
                hexpand
                min={0}
                max={1.5}
                step={0.01}
                value={volume}
                onNotifyValue={({ value }) => (speaker.volume = value)}
              />
              <button tooltipText="Advanced audio settings" onClicked={() => launch(["pavucontrol"])}>
                <label label="󰒓" />
              </button>
            </box>
          </box>

          <box class="panel-section calendar-section" orientation={Gtk.Orientation.VERTICAL} spacing={8}>
            <box>
              <label class="section-title" label="Calendar" xalign={0} hexpand />
              <label class="section-state" label={scheduleStatus} />
            </box>
            <Gtk.Calendar showWeekNumbers />
            <box class="schedule-list" orientation={Gtk.Orientation.VERTICAL} spacing={4}>
              <label
                class="panel-note"
                label="No timed blocks in today’s Schedule section."
                visible={schedule((entries) => entries.length === 0)}
                wrap
                xalign={0}
              />
              <For each={schedule}>
                {(entry) => (
                  <box class={`schedule-row ${entry.state}`} spacing={10}>
                    <label class="schedule-time" label={`${entry.start}\n${entry.end}`} xalign={0} />
                    <label label={entry.title} wrap xalign={0} hexpand />
                  </box>
                )}
              </For>
            </box>
            <box class="button-row" spacing={6}>
              <button hexpand onClicked={() => void refreshSchedule()}>
                <label label="Refresh" />
              </button>
              <button hexpand onClicked={() => launch(["obsidian"])}>
                <label label="Open Obsidian" />
              </button>
            </box>
          </box>

          <box class="panel-section" orientation={Gtk.Orientation.VERTICAL} spacing={8}>
            <box>
              <label class="section-title" label="Notifications" xalign={0} hexpand />
              <label class="section-state" label={activeNotices((items) => `${items.length} active`)} />
            </box>
            <box class="notification-list" orientation={Gtk.Orientation.VERTICAL} spacing={4}>
              <label
                class="panel-note"
                label="No notification history."
                visible={notices((items) => items.length === 0)}
                xalign={0}
              />
              <For each={notices}>
                {(notice) => (
                  <box class="notification-row" orientation={Gtk.Orientation.VERTICAL}>
                    <label class="notification-app" label={notice.appName} xalign={0} />
                    <label label={notice.summary} wrap xalign={0} />
                    <label
                      class="notification-body"
                      label={notice.body}
                      visible={Boolean(notice.body)}
                      wrap
                      xalign={0}
                      maxWidthChars={42}
                    />
                  </box>
                )}
              </For>
            </box>
            <box class="button-row" spacing={6}>
              <button
                hexpand
                onClicked={dismissAll}
              >
                <label label="Dismiss active" />
              </button>
              <button
                hexpand
                onClicked={clearNotificationHistory}
              >
                <label label="Clear history" />
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
