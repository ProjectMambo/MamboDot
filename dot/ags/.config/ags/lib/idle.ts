import { createState } from "ags"
import { execAsync } from "ags/process"
import { timeout } from "ags/time"
import Gio from "gi://Gio"
import GLib from "gi://GLib"

const [inhibited, setIdleInhibited] = createState(false)
export const idleInhibited = inhibited

let desired = false
let inhibitorFd: number | null = null
let retry: ReturnType<typeof timeout> | null = null
let failureNotified = false

function notifyFailure() {
  if (failureNotified) return
  failureNotified = true
  void execAsync([
    "notify-send",
    "--urgency=critical",
    "MamboDot idle inhibitor",
    "Could not acquire the logind inhibitor; retrying.",
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
  if (!desired || inhibitorFd !== null) return

  try {
    const bus = Gio.bus_get_sync(Gio.BusType.SYSTEM, null)
    const [reply, fds] = bus.call_with_unix_fd_list_sync(
      "org.freedesktop.login1",
      "/org/freedesktop/login1",
      "org.freedesktop.login1.Manager",
      "Inhibit",
      new GLib.Variant("(ssss)", [
        "idle",
        "MamboDot",
        "Keep the session awake",
        "block",
      ]),
      new GLib.VariantType("(h)"),
      Gio.DBusCallFlags.NONE,
      5000,
      null,
      null,
    )
    if (!fds) throw new Error("logind returned no inhibitor descriptor")
    const [handle] = reply.deepUnpack<[number]>()
    inhibitorFd = fds.get(handle)
    setIdleInhibited(true)
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
  const fd = inhibitorFd
  inhibitorFd = null
  setIdleInhibited(false)
  if (fd !== null) GLib.close(fd)
}

export function toggleIdleInhibitor() {
  if (desired) disableIdleInhibitor()
  else enableIdleInhibitor()
}
