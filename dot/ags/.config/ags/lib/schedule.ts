import GLib from "gi://GLib"

export type ScheduleEntry = {
  start: string
  end: string
  title: string
}

export function parseSchedule(markdown: string): ScheduleEntry[] {
  const lines = markdown.split(/\r?\n/)
  const start = lines.findIndex((line) => line === "## Schedule")
  if (start < 0) return []

  const entries: ScheduleEntry[] = []
  const row =
    /^-\s+([01]\d|2[0-3]):([0-5]\d)\s+-\s+([01]\d|2[0-3]):([0-5]\d)\s+(.+)$/

  for (const line of lines.slice(start + 1)) {
    if (/^##(?:\s|$)/.test(line)) break

    const match = line.match(row)
    if (match) {
      entries.push({
        start: `${match[1]}:${match[2]}`,
        end: `${match[3]}:${match[4]}`,
        title: match[5].trim().replaceAll("**", ""),
      })
    }
  }

  return entries
}

if (GLib.getenv("MAMBODOT_TEST") === "1") {
  const fixture = [
    "# Daily",
    "## Schedule",
    "",
    "- 07:00 - 07:30 **Breakfast**",
    "- 23:00 - 23:59 Wind down",
    "- 25:00 - 26:00 Invalid",
    "## Notes",
    "- 08:00 - 09:00 Outside section",
  ].join("\n")
  const parsed = parseSchedule(fixture)

  if (
    parsed.length !== 2 ||
    parsed[0].title !== "Breakfast" ||
    parsed[1].end !== "23:59"
  ) {
    throw new Error("schedule parser self-check failed")
  }
}
