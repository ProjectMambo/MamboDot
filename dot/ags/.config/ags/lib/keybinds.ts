import { readFile } from "ags/file"
import GLib from "gi://GLib"

export type KeybindEntry = {
  keys: string
  description: string
}

export type KeybindGroup = {
  title: string
  entries: KeybindEntry[]
}

function plain(cell: string) {
  return cell
    .replaceAll("`", "")
    .replaceAll("**", "")
    .replace(/\s+/g, " ")
    .trim()
}

export function parseKeybinds(markdown: string): KeybindGroup[] {
  const groups: KeybindGroup[] = []
  let title = ""

  for (const line of markdown.split(/\r?\n/)) {
    const heading = line.match(/^#{2,3}\s+(.+)$/)
    if (heading) {
      title = plain(heading[1])
      continue
    }

    const row = line.match(/^\|\s*(.*?)\s*\|\s*(.*?)\s*\|$/)
    if (!row || !title || row[1] === "Keybinding" || /^[-: ]+$/.test(row[1])) continue

    let group = groups.at(-1)
    if (!group || group.title !== title) {
      group = { title, entries: [] }
      groups.push(group)
    }
    group.entries.push({ keys: plain(row[1]), description: plain(row[2]) })
  }

  return groups
}

export function loadKeybinds() {
  const path = GLib.build_filenamev([
    GLib.get_home_dir(),
    "ProjectMambo",
    "MamboDot",
    "docs",
    "Keybinds.md",
  ])
  const groups = parseKeybinds(readFile(path))
  if (!groups.length) throw new Error("No keybind tables found")
  return groups
}

if (GLib.getenv("MAMBODOT_TEST") === "1") {
  const parsed = parseKeybinds([
    "## Shell",
    "| Keybinding | Description |",
    "|---|---|",
    "| `SUPER` `Q` | Open terminal |",
    "### Navigation",
    "| Keybinding | Description |",
    "|---|---|",
    "| `SUPER` `Grave` | Toggle scratchpad |",
  ].join("\n"))

  if (
    parsed.length !== 2 ||
    parsed[0].entries[0].keys !== "SUPER Q" ||
    parsed[1].entries[0].keys !== "SUPER Grave"
  ) {
    throw new Error("keybind parser self-check failed")
  }
}
