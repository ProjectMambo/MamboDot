import app from "ags/gtk4/app"
import { Astal, Gdk, Gtk } from "ags/gtk4"
import AstalHyprland from "gi://AstalHyprland"
import LeftSidebar, { type PanelContent } from "./LeftSidebar"
import RightSidebar from "./RightSidebar"

const hyprland = AstalHyprland.get_default()
const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor

function focusedMonitor() {
  const connector = hyprland?.focusedMonitor.name
  return app.get_monitors().find((monitor) => monitor.connector === connector)
}

export default function Sidebars(): Gtk.Window[] {
  const leftContent = LeftSidebar()
  const rightContent = RightSidebar()
  let backdrop: Astal.Window
  let left: Astal.Window
  let right: Astal.Window

  function close() {
    left.visible = false
    right.visible = false
  }

  function panel(
    side: "left" | "right",
    content: PanelContent,
  ) {
    let win: Astal.Window
    const sibling = () => (side === "left" ? right : left)

    return (
      <window
        $={(self) => (win = self)}
        visible={false}
        name={`sidebar-${side}`}
        namespace={`mambodot-sidebar-${side}`}
        class={`Sidebar ${side}`}
        marginTop={34}
        anchor={TOP | BOTTOM | (side === "left" ? LEFT : RIGHT)}
        layer={Astal.Layer.OVERLAY}
        exclusivity={Astal.Exclusivity.IGNORE}
        keymode={Astal.Keymode.EXCLUSIVE}
        onNotifyVisible={({ visible }) => {
          if (visible) {
            const monitor = focusedMonitor()
            if (monitor) {
              win.gdkmonitor = monitor
              backdrop.gdkmonitor = monitor
            }
            sibling().visible = false
            const launcher = app.get_window("launcher")
            if (launcher) launcher.visible = false
            backdrop.visible = true
            content.start()
          } else {
            content.stop()
            if (!sibling().visible) backdrop.visible = false
          }
        }}
      >
        <Gtk.EventControllerKey
          onKeyPressed={(_controller, keyval) => {
            if (keyval === Gdk.KEY_Escape) {
              win.visible = false
              return true
            }
            return false
          }}
        />
        {content.widget}
      </window>
    ) as Astal.Window
  }

  backdrop = (
    <window
      visible={false}
      name="sidebar-backdrop"
      namespace="mambodot-sidebar-backdrop"
      class="SidebarBackdrop"
      marginTop={34}
      anchor={TOP | BOTTOM | LEFT | RIGHT}
      layer={Astal.Layer.TOP}
      exclusivity={Astal.Exclusivity.IGNORE}
      keymode={Astal.Keymode.NONE}
    >
      <Gtk.GestureClick onPressed={close} />
      <box />
    </window>
  ) as Astal.Window
  left = panel("left", leftContent)
  right = panel("right", rightContent)

  return [backdrop, left, right]
}
