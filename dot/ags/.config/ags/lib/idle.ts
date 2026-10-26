import { createState } from "ags"
import { execAsync } from "ags/process"
import { timeout } from "ags/time"
import Gio from "gi://Gio"

const command = [
  "/usr/bin/systemd-inhibit",
  "--what=idle",
  "--who=MamboDot",
  "--why=Keep the session awake",
  "--mode=block",
  "/usr/bin/sleep",
  "infinity",
]

const [inhibited, setIdleInhibited] = createState(false)
export const idleInhibited = inhibited

let desired = false
let process: Gio.Subprocess | null = null
let retry: ReturnType<typeof timeout> | null = null
let failureNotified = false

function notifyFailure() {
  if (failureNotified) return
  failureNotified = true
  void execAsync([
    "notify-send",
    "--urgency=critical",
    "MamboDot idle inhibitor",
    "The inhibitor stopped unexpectedly; retrying.",
  ]).catch(() => {})
}

function scheduleRetry() {
  if (!desired || retry) return
  retry = timeout(2000, () => {
    retry = null
    start()
  })
}

function start() {
  if (!desired || process) return

  try {
    const child = Gio.Subprocess.new(command, Gio.SubprocessFlags.NONE)
    process = child
    setIdleInhibited(true)
    child.wait_async(null, (_source, result) => {
      try {
        child.wait_finish(result)
      } catch {
        // The process lifetime, not its exit code, owns the displayed state.
      }
      if (process !== child) return
      process = null
      setIdleInhibited(false)
      if (desired) {
        notifyFailure()
        scheduleRetry()
      }
    })
  } catch {
    setIdleInhibited(false)
    notifyFailure()
    scheduleRetry()
  }
}

export function enableIdleInhibitor() {
  if (!desired) failureNotified = false
  desired = true
  start()
}

export function disableIdleInhibitor() {
  desired = false
  retry?.cancel()
  retry = null
  const child = process
  process = null
  setIdleInhibited(false)
  child?.force_exit()
}

export function toggleIdleInhibitor() {
  if (desired) disableIdleInhibitor()
  else enableIdleInhibitor()
}
