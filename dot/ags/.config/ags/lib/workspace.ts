import GLib from "gi://GLib"

export function markAttention(ids: number[], id: number, focused: number) {
  return id === focused || ids.includes(id) ? ids : [...ids, id]
}

export function clearAttention(ids: number[], id: number) {
  return ids.filter((candidate) => candidate !== id)
}

export function workspaceClass(id: number, active: number, attention: number[]) {
  if (id === active) return "active"
  return attention.includes(id) ? "attention" : ""
}

if (GLib.getenv("MAMBODOT_TEST") === "1") {
  let attention = markAttention([], 12, 11)
  attention = markAttention(attention, 12, 11)
  attention = markAttention(attention, 11, 11)

  if (
    attention.length !== 1 ||
    workspaceClass(12, 11, attention) !== "attention" ||
    workspaceClass(12, 12, attention) !== "active" ||
    clearAttention(attention, 12).length !== 0
  ) {
    throw new Error("workspace attention self-check failed")
  }
}
