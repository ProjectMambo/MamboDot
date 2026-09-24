import { For, createBinding, createState, onCleanup } from "ags"
import app from "ags/gtk4/app"
import { Astal, Gdk, Gtk } from "ags/gtk4"
import { execAsync } from "ags/process"
import { createPoll } from "ags/time"
import AstalBattery from "gi://AstalBattery"
import AstalHyprland from "gi://AstalHyprland"
import AstalNetwork from "gi://AstalNetwork"
import AstalTray from "gi://AstalTray"
import AstalWp from "gi://AstalWp"
import GLib from "gi://GLib"
import Pango from "gi://Pango"
import { launchScoped } from "../lib/launch"

const hyprland = AstalHyprland.get_default()!
const [idleInhibited, setIdleInhibited] = createState(false)
let idleInhibitCookie = 0

function IdleInhibitor() {
  function toggle() {
    if (idleInhibitCookie) {
      app.uninhibit(idleInhibitCookie)
      idleInhibitCookie = 0
    } else {
      idleInhibitCookie = app.inhibit(
        null,
        Gtk.ApplicationInhibitFlags.IDLE,
        "Keep the session awake",
      )
      if (!idleInhibitCookie) {
        void execAsync(["notify-send", "MamboDot", "Could not enable idle inhibitor"])
      }
    }
    setIdleInhibited(idleInhibitCookie !== 0)
  }

  return (
    <button
      class={idleInhibited((active) => `status-button idle-inhibitor${active ? " active" : ""}`)}
      tooltipText={idleInhibited((active) => active
        ? "Idle inhibitor on · click to allow automatic locking"
        : "Idle inhibitor off · click to keep the session awake")}
      onClicked={toggle}
    >
      <label label={idleInhibited((active) => active ? "" : "")} />
    </button>
  )
}

function Workspaces({ gdkmonitor }: { gdkmonitor: Gdk.Monitor }) {
  const monitor = hyprland.get_monitor_by_name(gdkmonitor.connector ?? "")
  if (!monitor) return <box class="workspaces" />

  const active = createBinding(monitor, "activeWorkspace", "id")
  const offset = monitor.id * 10

  return (
    <box class="workspaces">
      {Array.from({ length: 10 }, (_, index) => {
        const id = offset + index + 1
        return (
          <button
            class={active((activeId) => (activeId === id ? "active" : ""))}
            tooltipText={`Workspace ${index + 1}`}
            onClicked={() => void hyprland.message(
              `dispatch hl.dsp.focus({ workspace = ${id} })`,
            )}
          >
            <label label={String(index + 1)} />
          </button>
        )
      })}
    </box>
  )
}

function Tray() {
  const tray = AstalTray.get_default()
  const items = createBinding(tray, "items")

  function setup(button: Gtk.MenuButton, item: AstalTray.TrayItem) {
    button.menuModel = item.menuModel
    button.insert_action_group("dbusmenu", item.actionGroup)
    item.connect("notify::action-group", () => {
      button.insert_action_group("dbusmenu", item.actionGroup)
    })
  }

  return (
    <box class="tray">
      <For each={items}>
        {(item) => (
          <menubutton class="tray-item" $={(button) => setup(button, item)}>
            <image gicon={createBinding(item, "gicon")} />
          </menubutton>
        )}
      </For>
    </box>
  )
}

function Network() {
  const network = AstalNetwork.get_default()
  const icon = createBinding(network, "wifi", "iconName")(
    (name) => name ?? "network-wired-symbolic",
  )
  const tooltip = createBinding(network, "wifi", "ssid")((ssid) => ssid || "Network")

  return (
    <button
      class="status-button network"
      tooltipText={tooltip}
      onClicked={() => launchScoped(["nm-connection-editor"])}
    >
      <image iconName={icon} />
    </button>
  )
}

function Audio() {
  const speaker = AstalWp.get_default().audio.defaultSpeaker
  const percent = createBinding(speaker, "volume")((volume) => `${Math.round(volume * 100)}%`)

  return (
    <button
      class="status-button audio"
      tooltipText="Audio settings"
      onClicked={() => launchScoped(["pavucontrol"])}
    >
      <box spacing={4}>
        <image iconName={createBinding(speaker, "volumeIcon")} />
        <label label={percent} />
      </box>
    </button>
  )
}

function Battery() {
  const battery = AstalBattery.get_default()
  const percent = createBinding(battery, "percentage")(
    (percentage) => `${Math.floor(percentage * 100)}%`,
  )

  return (
    <box class="battery" visible={createBinding(battery, "isPresent")} spacing={4}>
      <image iconName={createBinding(battery, "iconName")} />
      <label label={percent} />
    </box>
  )
}

function Clock() {
  const time = createPoll("", 1000, () => {
    return GLib.DateTime.new_now_local().format("%a, %d %b  %H:%M:%S")!
  })

  return <label label={time} />
}

export default function Bar({ gdkmonitor }: { gdkmonitor: Gdk.Monitor }) {
  let win: Astal.Window
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor
  const title = createBinding(hyprland, "focusedClient", "title")(
    (value) => value || "Hyprland",
  )

  onCleanup(() => win.destroy())

  return (
    <window
      $={(self) => (win = self)}
      visible
      name={`bar-${gdkmonitor.connector ?? "unknown"}`}
      class="Bar"
      namespace="mambodot-shell"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      application={app}
    >
      <centerbox>
        <box $type="start" class="bar-section" spacing={4}>
          <button
            class="launcher-button"
            tooltipText="Open application launcher"
            onClicked={() => app.toggle_window("launcher")}
          >
            <label label="󰣇" />
          </button>
          <button
            class="sidebar-button laptop-control"
            tooltipText="Laptop controls"
            onClicked={() => app.toggle_window("sidebar-left")}
          >
            <label label="󰌢" />
          </button>
          <Workspaces gdkmonitor={gdkmonitor} />
          <label
            class="window-title"
            label={title}
            maxWidthChars={42}
            ellipsize={Pango.EllipsizeMode.END}
            singleLineMode
          />
        </box>
        <box $type="center" class="bar-section clock">
          <Clock />
        </box>
        <box $type="end" class="bar-section status" spacing={2}>
          <IdleInhibitor />
          <Tray />
          <Network />
          <Audio />
          <Battery />
          <button
            class="sidebar-button quick-controls"
            tooltipText="Today and quick controls"
            onClicked={() => app.toggle_window("sidebar-right")}
          >
            <label label="󰒓" />
          </button>
        </box>
      </centerbox>
    </window>
  )
}
