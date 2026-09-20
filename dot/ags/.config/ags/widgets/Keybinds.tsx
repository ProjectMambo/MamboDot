import app from "ags/gtk4/app"
import { Astal, Gdk, Gtk } from "ags/gtk4"
import AstalHyprland from "gi://AstalHyprland"
import GLib from "gi://GLib"
import Graphene from "gi://Graphene"
import { loadKeybinds, type KeybindGroup } from "../lib/keybinds"

const hyprland = AstalHyprland.get_default()
const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor

export default function Keybinds(): Astal.Window {
  let win: Astal.Window
  let content: Gtk.Box
  let scroll: Gtk.ScrolledWindow
  let groups: KeybindGroup[]

  try {
    groups = loadKeybinds()
  } catch (error) {
    groups = [{
      title: "Unavailable",
      entries: [{
        keys: "",
        description: error instanceof Error ? error.message : String(error),
      }],
    }]
  }

  function closeOutside(
    _gesture: Gtk.GestureClick,
    _presses: number,
    x: number,
    y: number,
  ) {
    const [, bounds] = content.compute_bounds(win)
    if (!bounds.contains_point(new Graphene.Point({ x, y }))) win.visible = false
  }

  return (
    <window
      $={(self) => (win = self)}
      visible={false}
      name="keybinds"
      namespace="mambodot-keybinds"
      class="Keybinds"
      anchor={TOP | BOTTOM | LEFT | RIGHT}
      layer={Astal.Layer.OVERLAY}
      exclusivity={Astal.Exclusivity.IGNORE}
      keymode={Astal.Keymode.EXCLUSIVE}
      onNotifyVisible={({ visible }) => {
        if (!visible) return
        const focused = hyprland?.focusedMonitor.name
        const monitor = app.get_monitors().find(({ connector }) => connector === focused)
        if (monitor) win.gdkmonitor = monitor
        for (const name of ["launcher", "sidebar-left", "sidebar-right"]) {
          const other = app.get_window(name)
          if (other) other.visible = false
        }
        GLib.idle_add(GLib.PRIORITY_DEFAULT_IDLE, () => {
          scroll.vadjustment.value = scroll.vadjustment.lower
          return GLib.SOURCE_REMOVE
        })
      }}
    >
      <Gtk.EventControllerKey
        onKeyPressed={(_controller, keyval) => {
          if (keyval !== Gdk.KEY_Escape) return false
          win.visible = false
          return true
        }}
      />
      <Gtk.GestureClick onPressed={closeOutside} />
      <box
        $={(self) => (content = self)}
        name="keybinds-content"
        widthRequest={1080}
        heightRequest={820}
        valign={Gtk.Align.CENTER}
        halign={Gtk.Align.CENTER}
        orientation={Gtk.Orientation.VERTICAL}
      >
        <box class="keybinds-header">
          <box hexpand orientation={Gtk.Orientation.VERTICAL}>
            <label class="eyebrow" label="KEYBIND REFERENCE" xalign={0} />
            <label class="keybinds-title" label="MamboDot shortcuts" xalign={0} />
          </box>
          <label class="keybinds-hint" label="SUPER / · Escape closes" />
          <button tooltipText="Close" onClicked={() => (win.visible = false)}>
            <label label="󰅖" />
          </button>
        </box>
        <Gtk.ScrolledWindow
          $={(self) => (scroll = self)}
          class="keybinds-scroll"
          vexpand
          hscrollbarPolicy={Gtk.PolicyType.NEVER}
        >
          <box orientation={Gtk.Orientation.VERTICAL}>
            {groups.map((group) => (
              <box class="keybinds-group" orientation={Gtk.Orientation.VERTICAL}>
                <label class="keybinds-group-title" label={group.title} xalign={0} />
                {group.entries.map(({ keys, description }) => (
                  <box class="keybinds-row">
                    <label class="keybinds-keys" label={keys} xalign={0} />
                    <label
                      class="keybinds-description"
                      label={description}
                      hexpand
                      wrap
                      xalign={0}
                    />
                  </box>
                ))}
              </box>
            ))}
          </box>
        </Gtk.ScrolledWindow>
      </box>
    </window>
  ) as Astal.Window
}
