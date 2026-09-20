import GLib from "gi://GLib"

export type CpuSample = { idle: number; total: number }
export type DiskSample = { readSectors: number; writtenSectors: number }

export function parseCpuSample(text: string): CpuSample {
  const values = text.split(/\r?\n/, 1)[0].trim().split(/\s+/).slice(1).map(Number)
  return {
    idle: (values[3] || 0) + (values[4] || 0),
    total: values.reduce((sum, value) => sum + (value || 0), 0),
  }
}

export function cpuUsage(previous: CpuSample | null, current: CpuSample) {
  if (!previous) return 0
  const total = current.total - previous.total
  const idle = current.idle - previous.idle
  return total > 0 ? Math.max(0, Math.min(100, ((total - idle) / total) * 100)) : 0
}

export function parseDiskSample(text: string): DiskSample {
  let readSectors = 0
  let writtenSectors = 0
  for (const line of text.split(/\r?\n/)) {
    const fields = line.trim().split(/\s+/)
    if (!/^nvme\d+n\d+$/.test(fields[2] ?? "")) continue
    readSectors += Number(fields[5]) || 0
    writtenSectors += Number(fields[9]) || 0
  }
  return { readSectors, writtenSectors }
}

export function diskRates(
  previous: DiskSample | null,
  current: DiskSample,
  seconds: number,
) {
  if (!previous || seconds <= 0) return { read: 0, write: 0 }
  return {
    read: Math.max(0, current.readSectors - previous.readSectors) * 512 / seconds,
    write: Math.max(0, current.writtenSectors - previous.writtenSectors) * 512 / seconds,
  }
}

export function memoryUsage(text: string) {
  const total = Number(text.match(/^MemTotal:\s+(\d+)/m)?.[1]) || 0
  const available = Number(text.match(/^MemAvailable:\s+(\d+)/m)?.[1]) || 0
  return total > 0 ? { used: total - available, total } : { used: 0, total: 0 }
}

export function formatRate(bytes: number) {
  if (bytes < 1024 * 1024) return `${Math.round(bytes / 1024)} KiB/s`
  return `${(bytes / 1024 / 1024).toFixed(1)} MiB/s`
}

if (GLib.getenv("MAMBODOT_TEST") === "1") {
  const firstCpu = parseCpuSample("cpu  100 0 50 850 0 0 0 0\n")
  const secondCpu = parseCpuSample("cpu  150 0 100 950 0 0 0 0\n")
  const firstDisk = parseDiskSample("259 0 nvme0n1 1 0 100 0 1 0 200 0\n259 1 nvme0n1p1 1 0 999 0 1 0 999 0\n")
  const secondDisk = parseDiskSample("259 0 nvme0n1 1 0 612 0 1 0 1224 0\n")
  const rates = diskRates(firstDisk, secondDisk, 1)
  const memory = memoryUsage("MemTotal: 1000 kB\nMemAvailable: 400 kB\n")

  if (
    Math.round(cpuUsage(firstCpu, secondCpu)) !== 50 ||
    rates.read !== 262144 ||
    rates.write !== 524288 ||
    memory.used !== 600 ||
    formatRate(rates.write) !== "512 KiB/s"
  ) {
    throw new Error("hardware parser self-check failed")
  }
}
