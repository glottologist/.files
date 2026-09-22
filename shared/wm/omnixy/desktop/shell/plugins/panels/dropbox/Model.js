var IMAGE_EXTENSIONS = {
  jpg: true, jpeg: true, png: true, gif: true, webp: true, avif: true, heic: true,
  svg: true, bmp: true, tif: true, tiff: true
}

var VIDEO_EXTENSIONS = {
  mp4: true, mov: true, mkv: true, webm: true, avi: true, m4v: true, mpg: true,
  mpeg: true, wmv: true
}

var DOCUMENT_EXTENSIONS = {
  pdf: true, txt: true, md: true, doc: true, docx: true, xls: true, xlsx: true,
  ppt: true, pptx: true, odt: true, ods: true, odp: true, rtf: true, csv: true,
  pages: true, numbers: true, key: true
}

function parseStatus(raw) {
  var text = String(raw || "").trim()
  if (text === "") return defaultStatus()
  try {
    var parsed = JSON.parse(text)
    if (!parsed || typeof parsed !== "object") return defaultStatus()
    parsed.files = Array.isArray(parsed.files) ? parsed.files : []
    parsed.excluded = Array.isArray(parsed.excluded) ? parsed.excluded : []
    parsed.bandwidth = normaliseBandwidth(parsed.bandwidth)
    parsed.lanSync = parsed.lanSync !== false
    parsed.lanSyncRecorded = parsed.lanSyncRecorded === true
    parsed.autostart = normaliseAutostart(parsed.autostart)
    parsed.rootPath = String(parsed.rootPath || parsed.accountPath || "")
    return parsed
  } catch (e) {
    var failed = defaultStatus()
    failed.ok = false
    failed.lastError = "Failed to parse Dropbox status"
    return failed
  }
}

function defaultStatus() {
  return {
    ok: true,
    installed: false,
    running: false,
    authenticated: false,
    statusText: "Unavailable",
    accountPath: "",
    plan: "",
    usedBytes: 0,
    quotaBytes: 0,
    usagePercent: 0,
    quotaKnown: false,
    files: [],
    rootPath: "",
    excluded: [],
    bandwidth: normaliseBandwidth(null),
    lanSync: true,
    lanSyncRecorded: false,
    autostart: normaliseAutostart(null)
  }
}

var UPLOAD_MODES = ["unlimited", "auto", "manual"]

function normaliseBandwidth(raw) {
  var value = raw && typeof raw === "object" ? raw : {}
  var download = String(value.downloadMode || "unlimited")
  var upload = String(value.uploadMode || "unlimited")
  return {
    known: value.known === true,
    downloadMode: download === "manual" ? "manual" : "unlimited",
    uploadMode: UPLOAD_MODES.indexOf(upload) >= 0 ? upload : "unlimited",
    downloadLimit: positiveInt(value.downloadLimit),
    uploadLimit: positiveInt(value.uploadLimit)
  }
}

function normaliseAutostart(raw) {
  var value = raw && typeof raw === "object" ? raw : {}
  return {
    managed: value.managed === "systemd" ? "systemd" : "desktop",
    enabled: value.enabled === true
  }
}

function positiveInt(value) {
  var n = parseInt(String(value === undefined || value === null ? "0" : value), 10)
  return isFinite(n) && n > 0 ? n : 0
}

// Human label for one direction of the throttle: "Unlimited", "Auto" or the
// manual rate.
function bandwidthLabel(mode, limitKb) {
  if (mode === "manual") return formatRate(limitKb)
  if (mode === "auto") return "Auto"
  return "Unlimited"
}

function formatRate(limitKb) {
  var kb = positiveInt(limitKb)
  if (kb === 0) return "Unlimited"
  if (kb >= 1000) {
    var mb = kb / 1000
    return (mb >= 10 ? Math.round(mb) : mb.toFixed(1).replace(/\.0$/, "")) + " MB/s"
  }
  return kb + " KB/s"
}

// Arguments for `dropbox-cli throttle DOWNLOAD UPLOAD`. A manual mode with no
// usable rate falls back to unlimited rather than sending 0, which the CLI
// would reject.
function throttleArgs(bandwidth) {
  var b = normaliseBandwidth(bandwidth)
  var down = b.downloadMode === "manual" && b.downloadLimit > 0 ? String(b.downloadLimit) : "unlimited"
  var up = b.uploadMode === "manual" ? (b.uploadLimit > 0 ? String(b.uploadLimit) : "unlimited") : b.uploadMode
  return [down, up]
}

function nextUploadMode(mode) {
  var index = UPLOAD_MODES.indexOf(String(mode || "unlimited"))
  return UPLOAD_MODES[(index < 0 ? 0 : index + 1) % UPLOAD_MODES.length]
}

function parseFolders(raw) {
  var text = String(raw || "").trim()
  var failed = { ok: false, path: "", rootPath: "", folders: [], error: "Failed to read Dropbox folders" }
  if (text === "") return failed
  try {
    var parsed = JSON.parse(text)
    if (!parsed || typeof parsed !== "object") return failed
    if (parsed.ok !== true) return { ok: false, path: "", rootPath: "", folders: [], error: String(parsed.error || failed.error) }
    return {
      ok: true,
      path: String(parsed.path || ""),
      rootPath: String(parsed.rootPath || ""),
      folders: Array.isArray(parsed.folders) ? parsed.folders : [],
      error: ""
    }
  } catch (e) {
    return failed
  }
}

// The browser's breadcrumb: "/" at the Dropbox root, else the path inside it.
function relativeFolder(path, rootPath) {
  var p = String(path || "")
  var root = String(rootPath || "")
  if (root === "" || p === root) return "/"
  if (p.indexOf(root + "/") === 0) return p.substring(root.length)
  return p
}

function parentPath(path, rootPath) {
  var p = String(path || "")
  var root = String(rootPath || "")
  if (p === root || p === "") return root
  var index = p.lastIndexOf("/")
  if (index <= 0) return root
  var parent = p.substring(0, index)
  return parent.length < root.length ? root : parent
}

function folderMeta(folder) {
  if (!folder) return ""
  if (folder.excluded) return "Not synced"
  var inside = positiveInt(folder.excludedInside)
  if (inside > 0) return "Synced · " + inside + " excluded inside"
  return "Synced"
}

function fileExtension(name) {
  var value = String(name || "").toLowerCase()
  var index = value.lastIndexOf(".")
  return index >= 0 ? value.substring(index + 1) : ""
}

function fileKind(name) {
  var ext = fileExtension(name)
  if (IMAGE_EXTENSIONS[ext]) return "image"
  if (VIDEO_EXTENSIONS[ext]) return "video"
  if (DOCUMENT_EXTENSIONS[ext]) return "document"
  return "misc"
}

function fileGlyph(name) {
  var kind = fileKind(name)
  if (kind === "image") return "󰋩"
  if (kind === "video") return "󰈫"
  if (kind === "document") return "󰈙"
  return "󰈔"
}

function formatBytes(bytes) {
  var value = Number(bytes || 0)
  if (!isFinite(value) || value <= 0) return "0 B"
  var units = ["B", "KB", "MB", "GB", "TB"]
  var index = 0
  while (value >= 1000 && index < units.length - 1) {
    value = value / 1000
    index++
  }
  var decimals = value >= 100 || index === 0 ? 0 : (value >= 10 ? 1 : 2)
  return value.toFixed(decimals).replace(/\.0+$/, "").replace(/(\.\d)0$/, "$1") + " " + units[index]
}

function formatPercent(value) {
  var number = Number(value || 0)
  if (!isFinite(number) || number <= 0) return "0%"
  if (number >= 10) return Math.round(number) + "%"
  return number.toFixed(1).replace(/\.0$/, "") + "%"
}

function usageText(usedBytes, quotaBytes, quotaKnown) {
  if (quotaKnown && Number(quotaBytes || 0) > 0) {
    return formatBytes(usedBytes) + " of " + formatBytes(quotaBytes)
  }
  return formatBytes(usedBytes)
}

function relativeTime(timestampSec, nowMs) {
  var ts = Number(timestampSec || 0)
  if (!isFinite(ts) || ts <= 0) return "Unknown time"
  var now = nowMs === undefined ? Date.now() : Number(nowMs)
  var diff = Math.max(0, Math.floor((now - ts * 1000) / 1000))
  if (diff < 60) return "Just now"
  var minutes = Math.floor(diff / 60)
  if (minutes < 60) return minutes + "m ago"
  var hours = Math.floor(minutes / 60)
  if (hours < 24) return hours + "h ago"
  var days = Math.floor(hours / 24)
  if (days < 30) return days + "d ago"
  var months = Math.floor(days / 30)
  if (months < 12) return months + "mo ago"
  return Math.floor(days / 365) + "y ago"
}

function fileMeta(file, nowMs) {
  if (!file) return ""
  var parts = [relativeTime(file.modifiedTs, nowMs)]
  var folder = String(file.folder || "")
  if (folder !== "") parts.push(folder)
  return parts.join(" · ")
}

if (typeof module !== "undefined") {
  module.exports = {
    parseStatus: parseStatus,
    defaultStatus: defaultStatus,
    fileExtension: fileExtension,
    fileKind: fileKind,
    fileGlyph: fileGlyph,
    formatBytes: formatBytes,
    formatPercent: formatPercent,
    usageText: usageText,
    relativeTime: relativeTime,
    fileMeta: fileMeta,
    normaliseBandwidth: normaliseBandwidth,
    normaliseAutostart: normaliseAutostart,
    bandwidthLabel: bandwidthLabel,
    formatRate: formatRate,
    throttleArgs: throttleArgs,
    nextUploadMode: nextUploadMode,
    parseFolders: parseFolders,
    relativeFolder: relativeFolder,
    parentPath: parentPath,
    folderMeta: folderMeta
  }
}
