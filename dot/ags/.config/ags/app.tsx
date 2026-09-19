import { createBinding, For, This } from "ags"
import app from "ags/gtk4/app"
import Gtk from "gi://Gtk?version=4.0"
import style from "./style.scss"
import Bar from "./widgets/Bar"
import Launcher, { type LauncherController, type LauncherMode } from "./widgets/Launcher"
import Notifications from "./widgets/Notifications"
import Sidebars from "./widgets/Sidebars"

let launcher: LauncherController | null = null
const launcherModes: LauncherMode[] = ["apps", "run", "windows", "power", "clipboard"]

app.start({
  css: style,
  gtkTheme: "Adwaita",
  requestHandler(argv, respond) {
    const [command, requestedMode, option] = argv
    if (command === "bar" && requestedMode === "toggle" && argv.length === 2) {
      const bars = app.windows.filter(({ name }) => name.startsWith("bar-"))
      const visible = bars.some((bar) => bar.visible)
      bars.forEach((bar) => (bar.visible = !visible))
      respond("ok")
      return
    }
    if (
      command !== "launcher" ||
      !launcherModes.includes(requestedMode as LauncherMode) ||
      (argv.length !== 2 && !(
        argv.length === 3 &&
        requestedMode === "apps" &&
        option === "prime"
      ))
    ) {
      respond("Usage: ags request bar toggle | launcher apps [prime]|run|windows|power|clipboard")
      return
    }
    if (!launcher) {
      respond("Launcher is not ready")
      return
    }
    launcher.open(requestedMode as LauncherMode, option === "prime")
    respond("ok")
  },
  main() {
    launcher = Launcher()
    app.add_window(launcher.window)
    app.add_window(Notifications())
    Sidebars().forEach((window) => app.add_window(window))

    return (
      <For each={createBinding(app, "monitors")}>
        {(monitor) => (
          <This this={app}>
            <Bar gdkmonitor={monitor} />
          </This>
        )}
      </For>
    )
  },
})
