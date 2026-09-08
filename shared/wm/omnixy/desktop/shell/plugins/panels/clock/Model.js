// Pure date and format math for the clock widget and its calendar panel.
// Everything here is locale- and Qt-free so it can be unit tested under node
// (test/shell.d/clock-test.sh); the QML owns month/weekday naming through
// Qt.locale().

var MS_PER_DAY = 86400000

// Weekday indices match both JS Date.getDay() and QML's Locale.Sunday…
// Locale.Saturday, so a locale's firstDayOfWeek can be passed straight in.
var WEEKDAY_NAMES = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]

// ---- Bar label formats. Right-clicking the clock walks these in order and
//      writes the result back to shell.json, so the label the bar shows and
//      the format the config stores are always the same thing.
//
// The locale-shaped time presets are each followed by their 12-hour twin, so
// the walk from a 24-hour label to the same label in AM/PM is a single right
// click rather than a lap of the ring. The ISO preset is deliberately left
// without one: ISO 8601 writes time on a 24-hour clock, so an AM/PM variant
// would contradict the only thing that format is for.
var CLOCK_FORMATS = [
  "dddd HH:mm",
  "dddd h:mm AP",
  "HH:mm",
  "h:mm AP",
  "ddd d MMM HH:mm",
  "ddd d MMM h:mm AP",
  "d MMMM 'W'ww yyyy",
  "yyyy-MM-dd HH:mm"
]

// Vertical bars have room for a few stacked lines and nothing else, so the
// ring stays short. AM/PM costs a fourth line, which is why only the plain
// time carries it here.
var VERTICAL_CLOCK_FORMATS = [
  "HH\n—\nmm",
  "h\n—\nmm\nAP",
  "dd\nMMM\n'W'ww\n''yy",
  "HH\nmm"
]

function clockFormats(vertical) {
  return vertical ? VERTICAL_CLOCK_FORMATS.slice() : CLOCK_FORMATS.slice()
}

// The presets in a fixed order, plus the configured alternate and current
// format when they are something else. The order must not depend on which
// entry is current: cycling writes the result back to shell.json, and a ring
// that reshuffled itself around the current value would bounce between two
// entries instead of walking.
function clockFormatRing(configured, configuredAlt, presets) {
  var ring = []
  var candidates = (presets || []).concat([configuredAlt, configured])
  for (var i = 0; i < candidates.length; i++) {
    var format = String(candidates[i] === undefined || candidates[i] === null ? "" : candidates[i])
    if (format === "" || ring.indexOf(format) !== -1) continue
    ring.push(format)
  }
  return ring.length > 0 ? ring : ["HH:mm"]
}

// Next entry after `current`. An unknown current format (a hand-written one
// that is not in the ring) starts the walk at the top.
function nextClockFormat(ring, current) {
  if (!ring || ring.length === 0) return ""
  var index = ring.indexOf(String(current === undefined || current === null ? "" : current))
  return ring[(index + 1) % ring.length]
}

// Two-digit ISO week, substituted into a format's 'ww' token before Qt
// formats it -- Qt has no ISO week specifier of its own.
function isoWeekLiteral(year, month, day) {
  return pad2(isoWeek(year, month, day))
}

function pad2(value) {
  var n = Number(value)
  return (n < 10 ? "0" : "") + n
}

// Stable "yyyy-MM-dd" identity for a day, so a grid cell can be compared
// against today without dragging Date objects through bindings.
function dateKey(year, month, day) {
  return year + "-" + pad2(Number(month) + 1) + "-" + pad2(day)
}

function keyForDate(date) {
  return dateKey(date.getFullYear(), date.getMonth(), date.getDate())
}

function coerceWeekStart(value) {
  if (value === undefined || value === null) return null
  if (typeof value === "number")
    return isFinite(value) ? ((Math.round(value) % 7) + 7) % 7 : null

  var text = String(value).replace(/^\s+|\s+$/g, "").toLowerCase()
  if (text === "") return null

  for (var i = 0; i < WEEKDAY_NAMES.length; i++)
    if (WEEKDAY_NAMES[i] === text || WEEKDAY_NAMES[i].substr(0, 3) === text) return i

  var parsed = parseInt(text, 10)
  return isFinite(parsed) ? ((parsed % 7) + 7) % 7 : null
}

// Configured week start, falling back to the locale's own first day when
// the setting is missing or nonsense.
function normalizedWeekStart(value, fallback) {
  var configured = coerceWeekStart(value)
  if (configured !== null) return configured
  var fallbackStart = coerceWeekStart(fallback)
  return fallbackStart === null ? 1 : fallbackStart
}

function weekStartSettingName(index) {
  return WEEKDAY_NAMES[normalizedWeekStart(index, 1)]
}

// The toggle flips between the two conventions people actually switch
// between. A calendar configured to any other start (Saturday, say) is
// shown as-is and lands on Monday the first time it is toggled.
function toggledWeekStart(index) {
  return normalizedWeekStart(index, 1) === 1 ? 0 : 1
}

function weekdayOrder(weekStart) {
  var start = normalizedWeekStart(weekStart, 1)
  var out = []
  for (var i = 0; i < 7; i++) out.push((start + i) % 7)
  return out
}

// ISO-8601 week number: the week owning the Thursday of that date's
// Monday-based week. Mirrors the clock widget's 'ww' format token.
function isoWeek(year, month, day) {
  var date = new Date(Date.UTC(year, month, day))
  var weekday = date.getUTCDay() || 7
  date.setUTCDate(date.getUTCDate() + 4 - weekday)
  var yearStart = new Date(Date.UTC(date.getUTCFullYear(), 0, 1))
  return Math.ceil(((date.getTime() - yearStart.getTime()) / MS_PER_DAY + 1) / 7)
}

function dayOfYear(year, month, day) {
  return Math.round((Date.UTC(year, month, day) - Date.UTC(year, 0, 1)) / MS_PER_DAY) + 1
}

function daysInYear(year) {
  return dayOfYear(year, 11, 31)
}

// Share of the year already behind you: whole days completed over days in
// the year, so January 1 reads 0% and December 31 reads 100%.
function yearProgress(year, month, day) {
  var total = daysInYear(year)
  if (total <= 0) return 0
  return Math.max(0, Math.min(1, (dayOfYear(year, month, day) - 1) / total))
}

function yearProgressPercent(year, month, day) {
  return Math.round(yearProgress(year, month, day) * 100)
}

// Memento mori. The default span is a round number rather than anything from
// an actuarial table: the point of the bar is the reminder, not the
// arithmetic, and whoever wants a different number can say so.
var DEFAULT_LIFE_EXPECTANCY = 90

// A birth year rather than an age, so the bar keeps counting on its own
// instead of going stale the moment it is entered. 0 means "not set", which
// is also what a blank, malformed, future, or implausibly distant year means.
function parseBirthYear(value, currentYear) {
  var now = Math.round(Number(currentYear))
  if (!isFinite(now)) return 0
  var text = String(value === undefined || value === null ? "" : value).replace(/^\s+|\s+$/g, "")
  if (!/^\d{4}$/.test(text)) return 0
  var year = parseInt(text, 10)
  if (!isFinite(year) || year > now || year < now - 120) return 0
  return year
}

// Whole years, the way people say their age: born in 1979 makes you 47 for
// all of 2026, whichever side of your birthday today falls.
function ageFromBirthYear(birthYear, currentYear) {
  var born = parseBirthYear(birthYear, currentYear)
  if (born <= 0) return 0
  return Math.round(Number(currentYear)) - born
}

// 0 means "not set", which is also what a blank, negative, fractional, or
// absurd entry means — the life bar simply stays hidden.
function parseAge(value) {
  var text = String(value === undefined || value === null ? "" : value).replace(/^\s+|\s+$/g, "")
  if (!/^\d+$/.test(text)) return 0
  var years = parseInt(text, 10)
  if (!isFinite(years) || years <= 0 || years > 120) return 0
  return years
}

// Unset or nonsense falls back to the default rather than to zero, so the
// bar always has something to measure against.
function parseLifeExpectancy(value) {
  var text = String(value === undefined || value === null ? "" : value).replace(/^\s+|\s+$/g, "")
  if (!/^\d+$/.test(text)) return DEFAULT_LIFE_EXPECTANCY
  var years = parseInt(text, 10)
  if (!isFinite(years) || years <= 0 || years > 150) return DEFAULT_LIFE_EXPECTANCY
  return years
}

function lifeProgress(age, expectancy) {
  var years = parseAge(age)
  var span = parseLifeExpectancy(expectancy)
  if (years <= 0 || span <= 0) return 0
  return Math.max(0, Math.min(1, years / span))
}

function lifeProgressPercent(age, expectancy) {
  return Math.round(lifeProgress(age, expectancy) * 100)
}

// Always six rows of seven days. A fixed grid keeps the popup exactly the
// same height in every month, so stepping through the year never makes the
// panel jump under the pointer.
function monthGrid(year, month, weekStart, todayKey) {
  var start = normalizedWeekStart(weekStart, 1)
  var leading = (new Date(year, month, 1).getDay() - start + 7) % 7
  var cursor = new Date(year, month, 1 - leading)
  var today = String(todayKey || "")
  var weeks = []

  for (var w = 0; w < 6; w++) {
    var days = []
    var thursday = null
    for (var d = 0; d < 7; d++) {
      var cellYear = cursor.getFullYear()
      var cellMonth = cursor.getMonth()
      var cellDay = cursor.getDate()
      var weekday = cursor.getDay()
      var key = dateKey(cellYear, cellMonth, cellDay)
      if (weekday === 4) thursday = { year: cellYear, month: cellMonth, day: cellDay }
      days.push({
        key: key,
        year: cellYear,
        month: cellMonth,
        day: cellDay,
        weekday: weekday,
        inMonth: cellMonth === month && cellYear === year,
        weekend: weekday === 0 || weekday === 6,
        today: key === today
      })
      cursor.setDate(cursor.getDate() + 1)
    }
    // Number every row by the ISO week owning its Thursday. That is the
    // definition itself for Monday-start weeks, and the only answer that
    // stays stable for the other starts, where a row straddles two ISO
    // weeks but shares all of Monday through Thursday with one of them.
    var anchor = thursday || days[0]
    weeks.push({
      week: isoWeek(anchor.year, anchor.month, anchor.day),
      days: days
    })
  }
  return weeks
}

function stepMonth(year, month, delta) {
  var target = new Date(year, Number(month) + Number(delta), 1)
  return { year: target.getFullYear(), month: target.getMonth() }
}

// ---- World clocks. IANA ids persisted on the widget; labels and the
//      picker list live here so QML does not own the zone table.

var MAX_WORLD_CLOCKS = 8

var WORLD_CLOCK_ZONES = [
  { id: "UTC", label: "UTC", region: "UTC" },
  { id: "Pacific/Honolulu", label: "Honolulu", region: "Pacific" },
  { id: "America/Anchorage", label: "Anchorage", region: "America" },
  { id: "America/Los_Angeles", label: "Los Angeles", region: "America" },
  { id: "America/Denver", label: "Denver", region: "America" },
  { id: "America/Chicago", label: "Chicago", region: "America" },
  { id: "America/New_York", label: "New York", region: "America" },
  { id: "America/Toronto", label: "Toronto", region: "America" },
  { id: "America/Mexico_City", label: "Mexico City", region: "America" },
  { id: "America/Bogota", label: "Bogota", region: "America" },
  { id: "America/Lima", label: "Lima", region: "America" },
  { id: "America/Sao_Paulo", label: "Sao Paulo", region: "America" },
  { id: "America/Argentina/Buenos_Aires", label: "Buenos Aires", region: "America" },
  { id: "Atlantic/Reykjavik", label: "Reykjavik", region: "Atlantic" },
  { id: "Europe/London", label: "London", region: "Europe" },
  { id: "Europe/Dublin", label: "Dublin", region: "Europe" },
  { id: "Europe/Lisbon", label: "Lisbon", region: "Europe" },
  { id: "Europe/Paris", label: "Paris", region: "Europe" },
  { id: "Europe/Madrid", label: "Madrid", region: "Europe" },
  { id: "Europe/Berlin", label: "Berlin", region: "Europe" },
  { id: "Europe/Amsterdam", label: "Amsterdam", region: "Europe" },
  { id: "Europe/Rome", label: "Rome", region: "Europe" },
  { id: "Europe/Zurich", label: "Zurich", region: "Europe" },
  { id: "Europe/Stockholm", label: "Stockholm", region: "Europe" },
  { id: "Europe/Athens", label: "Athens", region: "Europe" },
  { id: "Europe/Helsinki", label: "Helsinki", region: "Europe" },
  { id: "Europe/Bucharest", label: "Bucharest", region: "Europe" },
  { id: "Europe/Moscow", label: "Moscow", region: "Europe" },
  { id: "Africa/Cairo", label: "Cairo", region: "Africa" },
  { id: "Africa/Johannesburg", label: "Johannesburg", region: "Africa" },
  { id: "Africa/Lagos", label: "Lagos", region: "Africa" },
  { id: "Africa/Nairobi", label: "Nairobi", region: "Africa" },
  { id: "Asia/Jerusalem", label: "Jerusalem", region: "Asia" },
  { id: "Asia/Dubai", label: "Dubai", region: "Asia" },
  { id: "Asia/Karachi", label: "Karachi", region: "Asia" },
  { id: "Asia/Kolkata", label: "Kolkata", region: "Asia" },
  { id: "Asia/Dhaka", label: "Dhaka", region: "Asia" },
  { id: "Asia/Bangkok", label: "Bangkok", region: "Asia" },
  { id: "Asia/Singapore", label: "Singapore", region: "Asia" },
  { id: "Asia/Hong_Kong", label: "Hong Kong", region: "Asia" },
  { id: "Asia/Shanghai", label: "Shanghai", region: "Asia" },
  { id: "Asia/Taipei", label: "Taipei", region: "Asia" },
  { id: "Asia/Seoul", label: "Seoul", region: "Asia" },
  { id: "Asia/Tokyo", label: "Tokyo", region: "Asia" },
  { id: "Australia/Perth", label: "Perth", region: "Australia" },
  { id: "Australia/Adelaide", label: "Adelaide", region: "Australia" },
  { id: "Australia/Sydney", label: "Sydney", region: "Australia" },
  { id: "Pacific/Auckland", label: "Auckland", region: "Pacific" },
  { id: "Pacific/Fiji", label: "Fiji", region: "Pacific" }
]

var POPULAR_WORLD_CLOCKS = [
  "America/New_York",
  "America/Los_Angeles",
  "Europe/London",
  "Europe/Paris",
  "Asia/Dubai",
  "Asia/Kolkata",
  "Asia/Singapore",
  "Asia/Tokyo",
  "Australia/Sydney",
  "Pacific/Auckland"
]

function isTimeZoneId(value) {
  var text = String(value === undefined || value === null ? "" : value).replace(/^\s+|\s+$/g, "")
  if (text === "UTC" || text === "GMT") return true
  return /^[A-Za-z_]+(\/[A-Za-z0-9_+-]+)+$/.test(text)
}

function parseTimeZones(value) {
  var raw
  if (value === undefined || value === null || value === "") raw = []
  else if (Array.isArray(value)) raw = value
  else if (typeof value === "object" && isFinite(Number(value.length))) {
    raw = []
    for (var i = 0; i < value.length; i++) raw.push(value[i])
  } else raw = [value]

  var out = []
  var seen = {}
  for (var i = 0; i < raw.length; i++) {
    var entry = raw[i]
    var id = ""
    if (entry && typeof entry === "object" && entry.id !== undefined) id = String(entry.id)
    else id = String(entry === undefined || entry === null ? "" : entry)
    id = id.replace(/^\s+|\s+$/g, "")
    if (!isTimeZoneId(id) || seen[id]) continue
    seen[id] = true
    out.push(id)
    if (out.length >= MAX_WORLD_CLOCKS) break
  }
  return out
}

function addTimeZone(list, id) {
  var current = parseTimeZones(list)
  var next = String(id === undefined || id === null ? "" : id).replace(/^\s+|\s+$/g, "")
  if (!isTimeZoneId(next) || current.indexOf(next) !== -1) return current
  if (current.length >= MAX_WORLD_CLOCKS) return current
  return current.concat([next])
}

function removeTimeZone(list, id) {
  var current = parseTimeZones(list)
  var target = String(id === undefined || id === null ? "" : id)
  var out = []
  for (var i = 0; i < current.length; i++)
    if (current[i] !== target) out.push(current[i])
  return out
}

function timeZoneLabel(id) {
  var zone = String(id === undefined || id === null ? "" : id)
  for (var i = 0; i < WORLD_CLOCK_ZONES.length; i++)
    if (WORLD_CLOCK_ZONES[i].id === zone) return WORLD_CLOCK_ZONES[i].label
  var parts = zone.split("/")
  var last = parts[parts.length - 1] || zone
  return last.replace(/_/g, " ")
}

function usesHour12(format) {
  return /ap/i.test(String(format === undefined || format === null ? "" : format))
}

function zoneEpoch(value) {
  if (value instanceof Date) return value.getTime()
  var ms = Number(value)
  return isFinite(ms) ? ms : 0
}

function formatInZone(epochMs, timeZone, options) {
  var ms = zoneEpoch(epochMs)
  if (ms <= 0 || !isTimeZoneId(timeZone)) return ""
  if (typeof Intl === "undefined" || !Intl.DateTimeFormat) return ""
  var opts = {}
  var given = options || {}
  for (var key in given) opts[key] = given[key]
  opts.timeZone = timeZone
  try {
    return new Intl.DateTimeFormat("en-GB", opts).format(new Date(ms))
  } catch (e) {
    return ""
  }
}

function zoneDateKey(epochMs, timeZone) {
  var ms = zoneEpoch(epochMs)
  if (ms <= 0) return ""
  if (typeof Intl === "undefined" || !Intl.DateTimeFormat) return ""
  var opts = { year: "numeric", month: "2-digit", day: "2-digit" }
  if (timeZone) {
    if (!isTimeZoneId(timeZone)) return ""
    opts.timeZone = timeZone
  }
  try {
    return new Intl.DateTimeFormat("en-CA", opts).format(new Date(ms))
  } catch (e) {
    return ""
  }
}

function zoneDayOffset(epochMs, timeZone, localTimeZone) {
  var there = zoneDateKey(epochMs, timeZone)
  var here = zoneDateKey(epochMs, localTimeZone || "")
  if (!there || !here) return 0
  var a = there.split("-")
  var b = here.split("-")
  if (a.length !== 3 || b.length !== 3) return 0
  var da = Date.UTC(Number(a[0]), Number(a[1]) - 1, Number(a[2]))
  var db = Date.UTC(Number(b[0]), Number(b[1]) - 1, Number(b[2]))
  if (!isFinite(da) || !isFinite(db)) return 0
  return Math.round((da - db) / MS_PER_DAY)
}

function zoneOffsetLabel(epochMs, timeZone) {
  var formatted = formatInZone(epochMs, timeZone, {
    hour: "2-digit",
    minute: "2-digit",
    hourCycle: "h23",
    timeZoneName: "shortOffset"
  })
  if (!formatted) return ""
  var parts = formatted.split(" ")
  return parts.length > 1 ? parts[parts.length - 1] : ""
}

function formatTimeInZone(epochMs, timeZone, hour12) {
  if (hour12)
    return formatInZone(epochMs, timeZone, { hour: "numeric", minute: "2-digit", hour12: true })
  return formatInZone(epochMs, timeZone, { hour: "2-digit", minute: "2-digit", hourCycle: "h23" })
}

function worldClockRows(list, epochMs, options) {
  var ids = parseTimeZones(list)
  var opts = options || {}
  var hour12 = opts.hour12 === true
  var localTimeZone = opts.localTimeZone || ""
  var rows = []
  for (var i = 0; i < ids.length; i++) {
    var id = ids[i]
    var dayOffset = zoneDayOffset(epochMs, id, localTimeZone)
    rows.push({
      id: id,
      label: timeZoneLabel(id),
      time: formatTimeInZone(epochMs, id, hour12) || "—",
      offset: zoneOffsetLabel(epochMs, id),
      dayOffset: dayOffset,
      dayOffsetLabel: dayOffset === 0 ? "" : (dayOffset > 0 ? "+" + dayOffset : String(dayOffset))
    })
  }
  return rows
}

function maxWorldClocks() {
  return MAX_WORLD_CLOCKS
}

function matchingTimeZones(query, exclude) {
  var q = String(query === undefined || query === null ? "" : query).replace(/^\s+|\s+$/g, "").toLowerCase()
  var skip = parseTimeZones(exclude)
  var skipped = {}
  for (var s = 0; s < skip.length; s++) skipped[skip[s]] = true

  var source = []
  if (q === "") {
    for (var p = 0; p < POPULAR_WORLD_CLOCKS.length; p++) {
      var popular = POPULAR_WORLD_CLOCKS[p]
      if (skipped[popular]) continue
      source.push({ id: popular, label: timeZoneLabel(popular), region: "" })
    }
  } else {
    for (var i = 0; i < WORLD_CLOCK_ZONES.length; i++) {
      var zone = WORLD_CLOCK_ZONES[i]
      if (skipped[zone.id]) continue
      var hay = (zone.id + " " + zone.label + " " + zone.region).toLowerCase()
      if (hay.indexOf(q) === -1) continue
      source.push(zone)
    }
    if (isTimeZoneId(query) && !skipped[String(query).replace(/^\s+|\s+$/g, "")] && source.length === 0) {
      var typed = String(query).replace(/^\s+|\s+$/g, "")
      source.push({ id: typed, label: timeZoneLabel(typed), region: "" })
    }
  }

  var limit = 6
  return source.length > limit ? source.slice(0, limit) : source
}

if (typeof module !== "undefined") {
  module.exports = {
    dateKey: dateKey,
    keyForDate: keyForDate,
    normalizedWeekStart: normalizedWeekStart,
    weekStartSettingName: weekStartSettingName,
    toggledWeekStart: toggledWeekStart,
    weekdayOrder: weekdayOrder,
    isoWeek: isoWeek,
    dayOfYear: dayOfYear,
    daysInYear: daysInYear,
    yearProgress: yearProgress,
    yearProgressPercent: yearProgressPercent,
    parseAge: parseAge,
    parseBirthYear: parseBirthYear,
    ageFromBirthYear: ageFromBirthYear,
    parseLifeExpectancy: parseLifeExpectancy,
    lifeProgress: lifeProgress,
    lifeProgressPercent: lifeProgressPercent,
    monthGrid: monthGrid,
    stepMonth: stepMonth,
    clockFormats: clockFormats,
    clockFormatRing: clockFormatRing,
    nextClockFormat: nextClockFormat,
    isoWeekLiteral: isoWeekLiteral,
    MAX_WORLD_CLOCKS: MAX_WORLD_CLOCKS,
    maxWorldClocks: maxWorldClocks,
    isTimeZoneId: isTimeZoneId,
    parseTimeZones: parseTimeZones,
    addTimeZone: addTimeZone,
    removeTimeZone: removeTimeZone,
    timeZoneLabel: timeZoneLabel,
    usesHour12: usesHour12,
    formatTimeInZone: formatTimeInZone,
    zoneDayOffset: zoneDayOffset,
    worldClockRows: worldClockRows,
    matchingTimeZones: matchingTimeZones
  }
}
