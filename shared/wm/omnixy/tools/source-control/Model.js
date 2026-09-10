// The state file omnixy-source-control-record writes: a read time, the window
// start, the login the split was made against, and two lists of pull requests
// (the login's own and everyone else's), newest activity first. Everything the
// panel shows is derived here so tools/source-control-model-test.sh can hold
// it still under node.

function parseState(raw) {
  var empty = { ok: false, time: 0, since: 0, login: "", mine: [], others: [] }
  var parsed
  try {
    parsed = JSON.parse(String(raw || ""))
  } catch (error) {
    return empty
  }
  if (!parsed || typeof parsed !== "object") return empty

  return {
    ok: true,
    time: finiteOr(parsed.time, 0),
    since: finiteOr(parsed.since, 0),
    login: String(parsed.login || ""),
    mine: cleanList(parsed.mine),
    others: cleanList(parsed.others)
  }
}

function finiteOr(value, fallback) {
  var n = Number(value)
  return isFinite(n) ? n : fallback
}

// A row needs somewhere to go and something to say; anything else is dropped
// rather than rendered as a blank line.
function cleanList(list) {
  var rows = []
  var items = Array.isArray(list) ? list : []
  for (var i = 0; i < items.length; i++) {
    var item = items[i] || {}
    var url = String(item.url || "")
    var repo = String(item.repo || "")
    var number = parseInt(item.number, 10)
    if (!url || !repo || !isFinite(number)) continue
    rows.push({
      repo: repo,
      number: number,
      title: String(item.title || ""),
      url: url,
      author: String(item.author || ""),
      state: String(item.state || ""),
      draft: item.draft === true,
      created: finiteOr(item.created, 0),
      closed: item.closed === null || item.closed === undefined ? 0 : finiteOr(item.closed, 0),
      opened: item.opened === true,
      merged: item.merged === true
    })
  }
  return rows
}

function activityTime(pr) {
  return pr.merged ? pr.closed : pr.created
}

// Repositories in order of their newest pull request, each holding its pull
// requests newest first, so the top of the panel is always the latest thing
// that happened.
function groupByRepo(list) {
  var groups = []
  var byRepo = {}
  var rows = Array.isArray(list) ? list : []

  for (var i = 0; i < rows.length; i++) {
    var pr = rows[i]
    var group = byRepo[pr.repo]
    if (!group) {
      group = { repo: pr.repo, prs: [], opened: 0, merged: 0, latest: 0 }
      byRepo[pr.repo] = group
      groups.push(group)
    }
    group.prs.push(pr)
    if (pr.opened) group.opened++
    if (pr.merged) group.merged++
    group.latest = Math.max(group.latest, activityTime(pr))
  }

  for (var g = 0; g < groups.length; g++) {
    groups[g].prs.sort(function(a, b) { return activityTime(b) - activityTime(a) })
  }
  groups.sort(function(a, b) { return b.latest - a.latest })
  return groups
}

// The panel is one column of rows of four kinds: a section heading, a
// repository heading with its counts, a pull request, or the line a section
// shows when it has nothing. Only pull-request rows take the cursor.
function panelRows(state) {
  var s = state || { mine: [], others: [] }
  return sectionRows("MY PULL REQUESTS", s.mine, "Nothing opened or merged by you in the last 24 hours.")
    .concat(sectionRows("FROM OTHERS", s.others, "Nothing opened or merged by anyone else in the last 24 hours."))
}

function sectionRows(title, list, emptyText) {
  var rows = [{ kind: "section", title: title, count: (list || []).length }]
  var groups = groupByRepo(list)
  if (groups.length === 0) {
    rows.push({ kind: "empty", text: emptyText })
    return rows
  }
  for (var g = 0; g < groups.length; g++) {
    var group = groups[g]
    rows.push({ kind: "repo", repo: group.repo, opened: group.opened, merged: group.merged })
    for (var p = 0; p < group.prs.length; p++) rows.push({ kind: "pr", pr: group.prs[p] })
  }
  return rows
}

function prRowIndexes(rows) {
  var indexes = []
  var items = Array.isArray(rows) ? rows : []
  for (var i = 0; i < items.length; i++) {
    if (items[i].kind === "pr") indexes.push(i)
  }
  return indexes
}

// The next pull-request row in the direction asked for, or the current one at
// either end; -1 when there is nothing to land on.
function stepCursor(rows, current, delta) {
  var indexes = prRowIndexes(rows)
  if (indexes.length === 0) return -1
  var position = indexes.indexOf(current)
  if (position === -1) return delta < 0 ? indexes[indexes.length - 1] : indexes[0]
  var next = Math.max(0, Math.min(indexes.length - 1, position + delta))
  return indexes[next]
}

function counts(state) {
  var s = state || { mine: [], others: [] }
  var all = (s.mine || []).concat(s.others || [])
  var opened = 0
  var merged = 0
  for (var i = 0; i < all.length; i++) {
    if (all[i].opened) opened++
    if (all[i].merged) merged++
  }
  return { opened: opened, merged: merged, total: all.length }
}

function summaryText(state) {
  var s = state || {}
  if (!s.ok) return "No record yet"
  var c = counts(s)
  return c.opened + " opened · " + c.merged + " merged in the last 24h"
}

function repoMeta(row) {
  var parts = []
  if (row.opened > 0) parts.push(row.opened + " opened")
  if (row.merged > 0) parts.push(row.merged + " merged")
  return parts.join(" · ")
}

function prTitle(pr) {
  return "#" + pr.number + " " + (pr.title || "")
}

function prMeta(pr, nowMs) {
  var parts = []
  if (pr.author) parts.push(pr.author)
  if (pr.opened) parts.push("opened " + relativeTime(pr.created, nowMs))
  if (pr.merged) parts.push("merged " + relativeTime(pr.closed, nowMs))
  else if (pr.state === "closed") parts.push("closed")
  else if (pr.draft) parts.push("draft")
  return parts.join(" · ")
}

// One character the row leads with: what the pull request is now, not what it
// did in the window. Merged and closed are final, open and draft are live.
function stateGlyph(pr) {
  if (pr.merged || pr.state === "merged") return "󰘬"
  if (pr.state === "closed") return "󰅙"
  if (pr.draft) return "󰑀"
  return "󰓂"
}

function stateLabel(pr) {
  if (pr.merged || pr.state === "merged") return "merged"
  if (pr.state === "closed") return "closed"
  if (pr.draft) return "draft"
  return "open"
}

function relativeTime(seconds, nowMs) {
  var when = parseFloat(seconds)
  var now = Number(nowMs)
  if (!isFinite(when) || when <= 0 || !isFinite(now)) return ""

  var age = Math.max(0, Math.floor(now / 1000 - when))
  if (age < 60) return "just now"
  if (age < 3600) return Math.floor(age / 60) + "m ago"
  if (age < 86400) return Math.floor(age / 3600) + "h ago"
  return Math.floor(age / 86400) + "d ago"
}

// The heading carries the age of the read: the first thing the panel has to
// answer is whether what it shows is current.
function updatedText(time, nowMs) {
  var relative = relativeTime(time, nowMs)
  return relative === "" ? "" : ("UPDATED " + relative).toUpperCase()
}

if (typeof module !== "undefined") {
  module.exports = {
    parseState: parseState,
    cleanList: cleanList,
    groupByRepo: groupByRepo,
    panelRows: panelRows,
    prRowIndexes: prRowIndexes,
    stepCursor: stepCursor,
    counts: counts,
    summaryText: summaryText,
    repoMeta: repoMeta,
    prTitle: prTitle,
    prMeta: prMeta,
    stateGlyph: stateGlyph,
    stateLabel: stateLabel,
    relativeTime: relativeTime,
    updatedText: updatedText
  }
}
