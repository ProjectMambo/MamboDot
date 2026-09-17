import { For, createState } from "ags"
import app from "ags/gtk4/app"
import { Astal, Gdk, Gtk } from "ags/gtk4"
import AstalHyprland from "gi://AstalHyprland"
import Gio from "gi://Gio"
import Graphene from "gi://Graphene"

type Application = {
  info: Gio.AppInfo
  name: string
  description: string
  nameLower: string
  searchable: string
  icon: Gio.Icon
}

const fallbackIcon = Gio.ThemedIcon.new("application-x-executable-symbolic")
const applications = Gio.AppInfo.get_all()
  .filter((info) => info.should_show())
  .map((info): Application => {
    const name = info.get_display_name()
    const description = info.get_description() ?? ""

    return {
      info,
      name,
      description,
      nameLower: name.toLocaleLowerCase(),
      searchable: [name, description, info.get_executable()]
        .join("\n")
        .toLocaleLowerCase(),
      icon: info.get_icon() ?? fallbackIcon,
    }
  })
  .sort((a, b) => a.name.localeCompare(b.name))

const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor

export default function Launcher() {
  let content: Gtk.Box
  let entry: Gtk.Entry
  let win: Astal.Window
  const hyprland = AstalHyprland.get_default()
  const [query, setQuery] = createState("")
  const [results, setResults] = createState<Application[]>([])

  function search(text: string) {
    const needle = text.trim().toLocaleLowerCase()
    const terms = needle.split(/\s+/).filter(Boolean)
    setQuery(needle)

    if (terms.length === 0) {
      setResults([])
      return
    }

    setResults(
      applications
        .filter((candidate) => terms.every((term) => candidate.searchable.includes(term)))
        .sort((a, b) => {
          const rankA = a.nameLower.startsWith(needle) ? 0 : 1
          const rankB = b.nameLower.startsWith(needle) ? 0 : 1
          return rankA - rankB || a.name.localeCompare(b.name)
        })
        .slice(0, 9),
    )
  }

  function launch(candidate?: Application) {
    if (!candidate) return

    try {
      const context = Gdk.Display.get_default()?.get_app_launch_context() ?? null
      if (candidate.info.launch(null, context)) win.visible = false
    } catch (error) {
      console.error(`Could not launch ${candidate.name}:`, error)
    }
  }

  function onKey(
    _controller: Gtk.EventControllerKey,
    keyval: number,
    _keycode: number,
    state: number,
  ) {
    if (keyval === Gdk.KEY_Escape) {
      win.visible = false
      return true
    }

    if (state & Gdk.ModifierType.ALT_MASK) {
      for (const number of [1, 2, 3, 4, 5, 6, 7, 8, 9] as const) {
        if (keyval === Gdk[`KEY_${number}`]) {
          launch(results.peek()[number - 1])
          return true
        }
      }
    }

    return false
  }

  function onClick(_gesture: Gtk.GestureClick, _presses: number, x: number, y: number) {
    const [, bounds] = content.compute_bounds(win)
    if (!bounds.contains_point(new Graphene.Point({ x, y }))) {
      win.visible = false
      return true
    }
    return false
  }

  return (
    <window
      $={(self) => (win = self)}
      name="launcher"
      class="Launcher"
      anchor={TOP | BOTTOM | LEFT | RIGHT}
      exclusivity={Astal.Exclusivity.IGNORE}
      keymode={Astal.Keymode.EXCLUSIVE}
      onNotifyVisible={({ visible }) => {
        if (visible) {
          const focused = hyprland?.focusedMonitor.name
          const monitor = app.get_monitors().find(({ connector }) => connector === focused)
          if (monitor) win.gdkmonitor = monitor
          entry.grab_focus()
        } else {
          entry.set_text("")
          search("")
        }
      }}
    >
      <Gtk.EventControllerKey onKeyPressed={onKey} />
      <Gtk.GestureClick onPressed={onClick} />
      <box
        $={(self) => (content = self)}
        name="launcher-content"
        valign={Gtk.Align.CENTER}
        halign={Gtk.Align.CENTER}
        orientation={Gtk.Orientation.VERTICAL}
      >
        <entry
          $={(self) => (entry = self)}
          onNotifyText={({ text }) => search(text)}
          onActivate={() => launch(results.peek()[0])}
          placeholderText="Search applications"
        />
        <label
          class="launcher-message"
          label={query((value) => (value ? "No matching applications" : "Type to search applications"))}
          visible={results((items) => items.length === 0)}
        />
        <box class="app-results" orientation={Gtk.Orientation.VERTICAL}>
          <For each={results}>
            {(candidate, index) => (
              <button class="app-row" onClicked={() => launch(candidate)}>
                <box spacing={12}>
                  <image gicon={candidate.icon} pixelSize={32} />
                  <box hexpand orientation={Gtk.Orientation.VERTICAL} valign={Gtk.Align.CENTER}>
                    <label label={candidate.name} xalign={0} />
                    <label
                      class="app-description"
                      label={candidate.description}
                      visible={candidate.description.length > 0}
                      xalign={0}
                      maxWidthChars={58}
                    />
                  </box>
                  <label class="shortcut" label={index((value) => `Alt+${value + 1}`)} />
                </box>
              </button>
            )}
          </For>
        </box>
      </box>
    </window>
  )
}
