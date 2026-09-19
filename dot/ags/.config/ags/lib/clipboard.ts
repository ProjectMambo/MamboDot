import Gio from "gi://Gio"
import GLib from "gi://GLib"

export type ClipboardItem = {
  id: string
  preview: string
}

const decoder = new TextDecoder("utf-8", { fatal: false })
const encoder = new TextEncoder()

function text(bytes: GLib.Bytes) {
  return decoder.decode(bytes.get_data())
}

function run(argv: string[], input: GLib.Bytes | null = null): Promise<GLib.Bytes> {
  let flags = Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_PIPE
  if (input !== null) flags |= Gio.SubprocessFlags.STDIN_PIPE
  const process = Gio.Subprocess.new(
    argv,
    flags,
  )

  return new Promise((resolve, reject) => {
    process.communicate_async(input, null, (source, result) => {
      try {
        const [, stdout, stderr] = source!.communicate_finish(result)
        if (source!.get_successful()) resolve(stdout)
        else reject(new Error(text(stderr).trim() || `${argv[0]} failed`))
      } catch (error) {
        reject(error)
      }
    })
  })
}

export function parseClipboard(bytes: Uint8Array): ClipboardItem[] {
  const items: ClipboardItem[] = []

  for (const line of decoder.decode(bytes).split(/\r?\n/)) {
    const separator = line.indexOf("\t")
    if (separator < 1) continue

    const id = line.slice(0, separator)
    if (!/^[0-9]+$/.test(id)) continue

    const preview = line
      .slice(separator + 1)
      .replace(/[\u0000-\u001f\u007f-\u009f\ufffd]+/g, " ")
      .replace(/\s+/g, " ")
      .trim()
    items.push({ id, preview: preview || "Clipboard item" })
  }

  return items
}

export async function listClipboard(): Promise<ClipboardItem[]> {
  return parseClipboard((await run(["cliphist", "list"])).get_data())
}

export async function copyClipboard(id: string) {
  if (!/^[0-9]+$/.test(id)) throw new Error("Invalid clipboard item")
  const content = await run(["cliphist", "decode"], GLib.Bytes.new(encoder.encode(id)))
  await run(["wl-copy"], content)
}

if (GLib.getenv("MAMBODOT_TEST") === "1") {
  const smoke = text(await run(["printf", "ok"]))
  const fixture = new Uint8Array([
    ...encoder.encode("42\tnewest\ninvalid\nnope\tignored\n41\t\n40\timage "),
    0x89,
    ...encoder.encode(" preview\n"),
  ])
  const parsed = parseClipboard(fixture)

  if (
    smoke !== "ok" ||
    parsed.length !== 3 ||
    parsed[0].id !== "42" ||
    parsed[1].preview !== "Clipboard item" ||
    parsed[2].preview !== "image preview"
  ) {
    throw new Error("clipboard parser self-check failed")
  }
}
