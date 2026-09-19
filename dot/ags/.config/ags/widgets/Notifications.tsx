import { For, createState } from "ags"
import app from "ags/gtk4/app"
import { Astal, Gtk } from "ags/gtk4"
import AstalHyprland from "gi://AstalHyprland"
import AstalNotifd from "gi://AstalNotifd"
import Gio from "gi://Gio"

export type NotificationHistoryItem = {
  id: number
  appName: string
  summary: string
  body: string
}

export const notifd = AstalNotifd.get_default()
export const [notificationHistory, setNotificationHistory] =
  createState<NotificationHistoryItem[]>([])
const [popups, setPopups] = createState<AstalNotifd.Notification[]>([])
const fallbackIcon = Gio.ThemedIcon.new("dialog-information-symbolic")
const hyprland = AstalHyprland.get_default()
let popupWindow: Astal.Window | undefined

notifd.defaultTimeout = 3000
notifd.ignoreTimeout = false

function icon(notification: AstalNotifd.Notification) {
  for (const value of [notification.image, notification.appIcon]) {
    if (!value) continue
    try {
      return Gio.Icon.new_for_string(value)
    } catch {
      // Try the next notification-provided icon.
    }
  }
  return fallbackIcon
}

function placeOnFocusedMonitor() {
  const focused = hyprland?.focusedMonitor.name
  const monitor = app.get_monitors().find(({ connector }) => connector === focused)
  if (popupWindow && monitor) popupWindow.gdkmonitor = monitor
}

notifd.connect("notified", (_self, id: number) => {
  const notification = notifd.get_notification(id)
  if (!notification) return

  setNotificationHistory((items) => [{
    id,
    appName: notification.appName || "Notification",
    summary: notification.summary || "Untitled",
    body: notification.body || "",
  }, ...items.filter((item) => item.id !== id)].slice(0, 50))

  if (!notifd.dontDisturb) {
    placeOnFocusedMonitor()
    setPopups((items) => [notification, ...items.filter((item) => item.id !== id)].slice(0, 5))
  }
})

notifd.connect("resolved", (_self, id: number) => {
  setPopups((items) => items.filter((item) => item.id !== id))
})

notifd.connect("notify::dont-disturb", () => {
  if (notifd.dontDisturb) setPopups([])
})

export function clearNotificationHistory() {
  setNotificationHistory([])
}

export function dismissAll() {
  for (const notification of [...notifd.notifications]) notification.dismiss()
}

function urgency(notification: AstalNotifd.Notification) {
  if (notification.urgency === AstalNotifd.Urgency.CRITICAL) return "critical"
  if (notification.urgency === AstalNotifd.Urgency.LOW) return "low"
  return "normal"
}

export default function Notifications(): Astal.Window {
  const { TOP, RIGHT } = Astal.WindowAnchor

  popupWindow = (
    <window
      visible={popups((items) => items.length > 0)}
      name="notification-popups"
      namespace="mambodot-notifications"
      class="Notifications"
      marginTop={44}
      marginRight={10}
      anchor={TOP | RIGHT}
      layer={Astal.Layer.OVERLAY}
      exclusivity={Astal.Exclusivity.IGNORE}
      keymode={Astal.Keymode.NONE}
      onNotifyVisible={({ visible }) => {
        if (visible) placeOnFocusedMonitor()
      }}
    >
      <box class="notification-popups" orientation={Gtk.Orientation.VERTICAL} spacing={6}>
        <For each={popups}>
          {(notification) => (
            <box
              class={`notification-popup ${urgency(notification)}`}
              orientation={Gtk.Orientation.VERTICAL}
              spacing={7}
            >
              <box spacing={10}>
                <image gicon={icon(notification)} pixelSize={28} valign={Gtk.Align.START} />
                <box hexpand orientation={Gtk.Orientation.VERTICAL}>
                  <label
                    class="notification-popup-app"
                    label={notification.appName || "Notification"}
                    xalign={0}
                  />
                  <label
                    class="notification-popup-summary"
                    label={notification.summary || "Untitled"}
                    wrap
                    xalign={0}
                  />
                </box>
                <button
                  class="notification-popup-dismiss"
                  tooltipText="Dismiss"
                  valign={Gtk.Align.START}
                  onClicked={() => notification.dismiss()}
                >
                  <label label="󰅖" />
                </button>
              </box>
              <label
                class="notification-popup-body"
                label={notification.body || ""}
                visible={Boolean(notification.body)}
                wrap
                xalign={0}
                maxWidthChars={48}
              />
              <box
                class="notification-popup-actions"
                visible={notification.actions.length > 0}
                spacing={6}
              >
                {notification.actions.map((action) => (
                    <button hexpand onClicked={() => action.invoke()}>
                      <label label={action.label} ellipsize={3} />
                    </button>
                ))}
              </box>
            </box>
          )}
        </For>
      </box>
    </window>
  ) as Astal.Window

  return popupWindow
}
