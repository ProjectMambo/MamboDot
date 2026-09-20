import { For, createComputed, createState } from "ags"
import app from "ags/gtk4/app"
import { Astal, Gdk, Gtk } from "ags/gtk4"
import { execAsync } from "ags/process"
import AstalHyprland from "gi://AstalHyprland"
import Gio from "gi://Gio"
import GLib from "gi://GLib"
import Graphene from "gi://Graphene"
import { copyClipboard, listClipboard, type ClipboardItem } from "../lib/clipboard"

export type LauncherMode = "apps" | "run" | "windows" | "power" | "clipboard"

export type LauncherController = {
  window: Gtk.Window
  open: (mode: LauncherMode, prime?: boolean) => void
}

type Application = {
  info: Gio.AppInfo
  name: string
  description: string
  nameLower: string
  searchable: string
  icon: Gio.Icon
}

type Candidate = {
  name: string
  description: string
  nameLower: string
  searchable: string
  icon: Gio.Icon
  run: () => boolean | void
  confirm?: string
}

const fallbackIcon = Gio.ThemedIcon.new("application-x-executable-symbolic")
const commandIcon = Gio.ThemedIcon.new("utilities-terminal-symbolic")
const windowIcon = Gio.ThemedIcon.new("focus-windows-symbolic")
const powerScript = GLib.build_filenamev([
  GLib.get_home_dir(),
  ".local",
  "bin",
  "powermenu.sh",
])
const clipboardIcon = Gio.ThemedIcon.new("edit-paste-symbolic")
const modeLabels: Array<[LauncherMode, string]> = [
  ["apps", "Apps"],
  ["run", "Run"],
  ["windows", "Windows"],
  ["power", "Power"],
  ["clipboard", "Clipboard"],
]
const powerActions = [
  ["lock", "Lock", "Lock this session", "system-lock-screen-symbolic", ""],
  ["suspend", "Suspend", "Suspend this computer", "system-suspend-symbolic", "Suspend now?"],
  ["hibernate", "Hibernate", "Hibernate this computer", "system-hibernate-symbolic", "Hibernate now?"],
  ["logout", "Log out", "End this Hyprland session", "system-log-out-symbolic", "Log out now?"],
  ["reboot", "Restart", "Restart this computer", "system-reboot-symbolic", "Restart now?"],
  ["windows", "Restart to Windows", "Select Windows for the next boot", "computer-symbolic", "Restart into Windows now?"],
  ["shutdown", "Shut down", "Power off this computer", "system-shutdown-symbolic", "Shut down now?"],
] as const
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

function matches(items: Candidate[], text: string, rank = true) {
  const needle = text.trim().toLocaleLowerCase()
  const terms = needle.split(/\s+/).filter(Boolean)
  if (!needle) return items.slice(0, 9)

  const filtered = items
    .filter((candidate) => terms.every((term) => candidate.searchable.includes(term)))
  if (rank) {
    filtered.sort((a, b) => {
      const rankA = a.nameLower.startsWith(needle) ? 0 : 1
      const rankB = b.nameLower.startsWith(needle) ? 0 : 1
      return rankA - rankB || a.name.localeCompare(b.name)
    })
  }
  return filtered.slice(0, 9)
}

export default function Launcher(): LauncherController {
  let content: Gtk.Box
  let entry: Gtk.Entry
  let win: Astal.Window
  let pending: Candidate | undefined
  let clipboardItems: ClipboardItem[] = []
  let clipboardGeneration = 0
  let clipboardLoading = false
  const hyprland = AstalHyprland.get_default()
  const [mode, setMode] = createState<LauncherMode>("apps")
  const [prime, setPrime] = createState(false)
  const [results, setResults] = createState<Candidate[]>([])
  const [empty, setEmpty] = createState("Type to search applications")
  const [confirmation, setConfirmation] = createState("")
  const [message, setMessage] = createState("")
  const [placeholder, setPlaceholder] = createState("Search applications")
  const showEmpty = createComputed(() => results().length === 0 && !message())

  function launchApplication(candidate: Application) {
    const context = Gdk.Display.get_default()?.get_app_launch_context() ?? null
    if (prime.peek() && context) {
      context.setenv("__NV_PRIME_RENDER_OFFLOAD", "1")
      context.setenv("__VK_LAYER_NV_optimus", "NVIDIA_only")
      context.setenv("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
    }
    return candidate.info.launch([], context)
  }

  function applicationCandidates(): Candidate[] {
    return applications.map((candidate) => ({
      ...candidate,
      description: prime.peek()
        ? ["Dedicated GPU", candidate.description].filter(Boolean).join(" · ")
        : candidate.description,
      run: () => launchApplication(candidate),
    }))
  }

  function runCandidate(text: string): Candidate[] {
    const command = text.trim()
    if (!command) return []

    return [{
      name: command,
      description: "Run arguments directly; shell operators are not expanded",
      nameLower: command.toLocaleLowerCase(),
      searchable: command.toLocaleLowerCase(),
      icon: commandIcon,
      run: () => {
        const [, argv] = GLib.shell_parse_argv(command)
        Gio.Subprocess.new(argv, Gio.SubprocessFlags.NONE)
      },
    }]
  }

  function windowCandidates(): Candidate[] {
    return (hyprland?.clients ?? [])
      .filter((client) => client.mapped)
      .map((client) => {
        const name = client.title || client.class || "Untitled window"
        const description = [client.class, `Workspace ${client.workspace.id}`]
          .filter(Boolean)
          .join(" · ")
        return {
          name,
          description,
          nameLower: name.toLocaleLowerCase(),
          searchable: `${name}\n${description}`.toLocaleLowerCase(),
          icon: windowIcon,
          run: () => {
            const response = hyprland.message(
              `dispatch hl.dsp.focus({ window = "address:0x${client.address}" })`,
            )
            if (response.trim() !== "ok") throw Error(response.trim())
          },
        }
      })
  }

  function powerCandidates(): Candidate[] {
    return powerActions.map(([id, name, description, icon, confirm]) => ({
      name,
      description,
      nameLower: name.toLocaleLowerCase(),
      searchable: `${name}\n${description}`.toLocaleLowerCase(),
      icon: Gio.ThemedIcon.new(icon),
      confirm: confirm || undefined,
      run: () => {
        void execAsync([powerScript, id]).catch((error) => {
          win.visible = true
          setMessage(`Could not ${name.toLocaleLowerCase()}: ${error instanceof Error ? error.message : String(error)}`)
        })
      },
    }))
  }

  function clipboardCandidates(): Candidate[] {
    return clipboardItems.map(({ id, preview }) => ({
      name: preview,
      description: "Clipboard history",
      nameLower: preview.toLocaleLowerCase(),
      searchable: preview.toLocaleLowerCase(),
      icon: clipboardIcon,
      run: () => {
        void copyClipboard(id).catch((error) => {
          win.visible = true
          setMessage(`Could not copy clipboard item: ${error instanceof Error ? error.message : String(error)}`)
        })
      },
    }))
  }

  async function refreshClipboard() {
    const generation = ++clipboardGeneration
    clipboardLoading = true
    search("", "clipboard")
    try {
      const items = await listClipboard()
      if (generation !== clipboardGeneration || mode.peek() !== "clipboard") return
      clipboardItems = items
      clipboardLoading = false
      search(entry.text, "clipboard")
    } catch (error) {
      if (generation !== clipboardGeneration || mode.peek() !== "clipboard") return
      clipboardLoading = false
      setResults([])
      setMessage(`Could not load clipboard history: ${error instanceof Error ? error.message : String(error)}`)
    }
  }

  function search(text: string, selected = mode.peek()) {
    setMessage("")
    const query = text.trim()

    if (selected === "apps") {
      setResults(query ? matches(applicationCandidates(), query) : [])
      setEmpty(query ? "No matching applications" : "Type to search applications")
    } else if (selected === "run") {
      setResults(runCandidate(query))
      setEmpty("Type a command and its arguments")
    } else if (selected === "windows") {
      setResults(matches(windowCandidates(), query))
      setEmpty(query ? "No matching windows" : "No open windows")
    } else if (selected === "power") {
      setResults(matches(powerCandidates(), query))
      setEmpty(query ? "No matching power actions" : "No power actions available")
    } else if (clipboardLoading) {
      setResults([])
      setEmpty("Loading clipboard history…")
    } else {
      setResults(matches(clipboardCandidates(), query, false))
      setEmpty(query ? "No matching clipboard items" : "No clipboard history")
    }
  }

  function cancelConfirmation() {
    pending = undefined
    setConfirmation("")
  }

  function activate(candidate?: Candidate, confirmed = false) {
    if (!candidate) return
    if (candidate.confirm && !confirmed) {
      pending = candidate
      setConfirmation(candidate.confirm)
      return
    }

    cancelConfirmation()
    setMessage("")
    try {
      if (candidate.run() !== false) win.visible = false
    } catch (error) {
      setMessage(`Could not open ${candidate.name}: ${error instanceof Error ? error.message : String(error)}`)
    }
  }

  function selectMode(next: LauncherMode, dedicated = false) {
    cancelConfirmation()
    setMode(next)
    setPrime(next === "apps" && dedicated)
    setPlaceholder(({
      apps: dedicated ? "Search applications · dedicated GPU" : "Search applications",
      run: "Run a command",
      windows: "Find an open window",
      power: "Find a power action",
      clipboard: "Search clipboard history",
    })[next])
    entry.set_text("")
    if (next === "clipboard") void refreshClipboard()
    else {
      clipboardGeneration++
      clipboardLoading = false
      search("", next)
    }
  }

  function onKey(
    _controller: Gtk.EventControllerKey,
    keyval: number,
    _keycode: number,
    state: number,
  ) {
    if (keyval === Gdk.KEY_Escape) {
      if (pending) cancelConfirmation()
      else win.visible = false
      return true
    }

    if (state & Gdk.ModifierType.CONTROL_MASK) {
      for (const [index, [next]] of modeLabels.entries()) {
        if (keyval === Gdk[`KEY_${index + 1}`]) {
          selectMode(next)
          return true
        }
      }
    }

    if (!pending && state & Gdk.ModifierType.ALT_MASK) {
      for (const number of [1, 2, 3, 4, 5, 6, 7, 8, 9] as const) {
        if (keyval === Gdk[`KEY_${number}`]) {
          activate(results.peek()[number - 1])
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

  win = (
    <window
      name="launcher"
      class="Launcher"
      anchor={TOP | BOTTOM | LEFT | RIGHT}
      exclusivity={Astal.Exclusivity.IGNORE}
      keymode={Astal.Keymode.EXCLUSIVE}
      onNotifyVisible={({ visible }) => {
        if (visible) {
          const left = app.get_window("sidebar-left")
          const right = app.get_window("sidebar-right")
          const keybinds = app.get_window("keybinds")
          if (left) left.visible = false
          if (right) right.visible = false
          if (keybinds) keybinds.visible = false
          const focused = hyprland?.focusedMonitor.name
          const monitor = app.get_monitors().find(({ connector }) => connector === focused)
          if (monitor) win.gdkmonitor = monitor
          search(entry.text)
          entry.grab_focus()
        } else {
          clipboardGeneration++
          clipboardLoading = false
          entry.set_text("")
          setMode("apps")
          setPrime(false)
          setPlaceholder("Search applications")
          cancelConfirmation()
          setMessage("")
          search("", "apps")
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
        <box class="launcher-modes" homogeneous spacing={4}>
          {modeLabels.map(([id, label], index) => (
            <button
              class={mode((current) => (current === id ? "active" : ""))}
              onClicked={() => selectMode(id)}
            >
              <label label={`${label}  Ctrl+${index + 1}`} />
            </button>
          ))}
        </box>
        <entry
          $={(self) => (entry = self)}
          onNotifyText={({ text }) => {
            if (pending) cancelConfirmation()
            search(text)
          }}
          onActivate={() => pending ? activate(pending, true) : activate(results.peek()[0])}
          placeholderText={placeholder}
        />
        <box
          class="launcher-confirm"
          visible={confirmation((value) => value.length > 0)}
          orientation={Gtk.Orientation.VERTICAL}
          spacing={8}
        >
          <label label={confirmation} wrap xalign={0} />
          <box homogeneous spacing={6}>
            <button onClicked={cancelConfirmation}>
              <label label="Cancel" />
            </button>
            <button class="destructive" onClicked={() => activate(pending, true)}>
              <label label="Confirm" />
            </button>
          </box>
        </box>
        <label
          class="launcher-message error"
          label={message}
          visible={message((value) => value.length > 0)}
          wrap
        />
        <label
          class="launcher-message"
          label={empty}
          visible={showEmpty}
        />
        <box class="app-results" orientation={Gtk.Orientation.VERTICAL}>
          <For each={results}>
            {(candidate, index) => (
              <button class="app-row" onClicked={() => activate(candidate)}>
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
  ) as Astal.Window

  return {
    window: win,
    open(next, dedicated = false) {
      if (win.visible && mode.peek() === next && prime.peek() === dedicated) {
        win.visible = false
        return
      }
      selectMode(next, dedicated)
      win.visible = true
    },
  }
}
