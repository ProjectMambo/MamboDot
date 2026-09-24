import Gio from "gi://Gio"
import GLib from "gi://GLib"

const scope = [
  "/usr/bin/systemd-run",
  "--user",
  "--scope",
  "--collect",
  "--quiet",
  "--slice=app.slice",
]

export function scopeCommand(argv: string[], environment: Record<string, string> = {}) {
  return [
    ...scope,
    ...Object.entries(environment).map(([name, value]) => `--setenv=${name}=${value}`),
    "--",
    ...argv,
  ]
}

export function launchScoped(argv: string[], environment: Record<string, string> = {}) {
  Gio.Subprocess.new(scopeCommand(argv, environment), Gio.SubprocessFlags.NONE)
}

if (GLib.getenv("MAMBODOT_TEST") === "1") {
  const command = scopeCommand(["printf", "hello world"], { TEST: "a=b" })
  if (
    command.join("\n") !== [
      ...scope,
      "--setenv=TEST=a=b",
      "--",
      "printf",
      "hello world",
    ].join("\n")
  ) {
    throw new Error("scoped launcher self-check failed")
  }
}
