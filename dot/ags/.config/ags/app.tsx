import { createBinding, For, This } from "ags"
import app from "ags/gtk4/app"
import Gtk from "gi://Gtk?version=4.0"
import style from "./style.scss"
import Bar from "./widgets/Bar"
import Launcher from "./widgets/Launcher"
import Sidebars from "./widgets/Sidebars"

app.start({
  css: style,
  gtkTheme: "Adwaita",
  main() {
    app.add_window(Launcher() as Gtk.Window)
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
