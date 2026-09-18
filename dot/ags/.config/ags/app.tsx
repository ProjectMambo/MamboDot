import { createBinding, For, This } from "ags"
import app from "ags/gtk4/app"
import Gtk from "gi://Gtk?version=4.0"
import style from "./style.scss"
import Bar from "./widgets/Bar"
import Launcher, { type LauncherController, type LauncherMode } from "./widgets/Launcher"
import Sidebars from "./widgets/Sidebars"

let launcher: LauncherController | null = null
const launcherModes: LauncherMode[] = ["apps", "run", "windows", "power"]

app.start({
  css: style,
  gtkTheme: "Adwaita",
  requestHandler(argv, respond) {
    const [command, requestedMode, option] = argv
    if (
      command !== "launcher" ||
      !launcherModes.includes(requestedMode as LauncherMode) ||
      (argv.length !== 2 && !(
        argv.length === 3 &&
        requestedMode === "apps" &&
        option === "prime"
      ))
    ) {
      respond("Usage: ags request launcher apps [prime]|run|windows|power")
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
