#!/usr/bin/env bash
# The source-control panel's Model.js helpers.
set -uo pipefail
model="$(cd "$(dirname "$0")" && pwd)/../desktop/shell/plugins/panels/source-control/Model.js"
fail() { echo "FAIL $1"; exit 1; }
[ -f "$model" ] || fail "Model.js missing"

node --input-type=commonjs - "$model" <<'EOF'
const assert = require("assert")
const Model = require(process.argv[2])

const now = 1789000000
const nowMs = now * 1000
const pr = (over) => Object.assign({
  repo: "Irys-xyz/irys", number: 1, title: "t", url: "https://github.com/Irys-xyz/irys/pull/1",
  author: "glottologist", state: "open", draft: false,
  created: now - 3600, closed: null, opened: true, merged: false
}, over)

const raw = JSON.stringify({
  time: now,
  since: now - 86400,
  login: "glottologist",
  mine: [
    pr({ number: 1566, state: "merged", created: now - 7200, closed: now - 600, opened: true, merged: true }),
    pr({ number: 1565, title: "fix(metrics)", created: now - 5400 }),
    pr({ repo: "Irys-xyz/ansible", number: 36, url: "https://github.com/Irys-xyz/ansible/pull/36",
         state: "merged", created: now - 90000, closed: now - 300, opened: false, merged: true }),
    { url: "", repo: "x", number: 1 },
    { url: "https://example", repo: "", number: 2 }
  ],
  others: []
})

const state = Model.parseState(raw)
assert.strictEqual(state.ok, true)
assert.strictEqual(state.login, "glottologist")
assert.strictEqual(state.mine.length, 3, "rows without a url or repo are dropped")
assert.strictEqual(state.mine[2].closed, now - 300)
assert.strictEqual(state.mine[1].closed, 0, "a null closed time is carried as 0")

assert.strictEqual(Model.parseState("").ok, false)
assert.strictEqual(Model.parseState("{not json").ok, false)
assert.deepStrictEqual(Model.parseState("[]").mine, [])
assert.deepStrictEqual(Model.parseState(null).others, [])

// Repositories order by their newest activity: ansible merged 300s ago beats
// irys at 600s; inside irys the merge (600s) precedes the open PR (5400s).
const groups = Model.groupByRepo(state.mine)
assert.deepStrictEqual(groups.map(g => g.repo), ["Irys-xyz/ansible", "Irys-xyz/irys"])
assert.deepStrictEqual(groups[1].prs.map(p => p.number), [1566, 1565])
assert.strictEqual(groups[1].opened, 2)
assert.strictEqual(groups[1].merged, 1)
assert.strictEqual(groups[0].opened, 0)
assert.strictEqual(groups[0].merged, 1)

const rows = Model.panelRows(state)
assert.deepStrictEqual(rows.map(r => r.kind),
  ["section", "repo", "pr", "repo", "pr", "pr", "section", "empty"])
assert.strictEqual(rows[0].title, "MY PULL REQUESTS")
assert.strictEqual(rows[0].count, 3)
assert.strictEqual(rows[6].title, "FROM OTHERS")
assert.strictEqual(rows[6].count, 0)
assert.match(rows[7].text, /anyone else/)

assert.deepStrictEqual(Model.prRowIndexes(rows), [2, 4, 5])
assert.strictEqual(Model.stepCursor(rows, -1, 1), 2, "no cursor steps onto the first PR")
assert.strictEqual(Model.stepCursor(rows, -1, -1), 5, "no cursor steps back onto the last PR")
assert.strictEqual(Model.stepCursor(rows, 2, 1), 4)
assert.strictEqual(Model.stepCursor(rows, 5, 1), 5, "the cursor stops at the end")
assert.strictEqual(Model.stepCursor(rows, 2, -1), 2, "the cursor stops at the start")
assert.strictEqual(Model.stepCursor(Model.panelRows(Model.parseState("")), -1, 1), -1)

assert.deepStrictEqual(Model.counts(state), { opened: 2, merged: 2, total: 3 })
assert.strictEqual(Model.summaryText(state), "2 opened · 2 merged in the last 24h")
assert.strictEqual(Model.summaryText(Model.parseState("")), "No record yet")

assert.strictEqual(Model.repoMeta(rows[3]), "2 opened · 1 merged")
assert.strictEqual(Model.repoMeta(rows[1]), "1 merged")

assert.strictEqual(Model.prTitle(state.mine[1]), "#1565 fix(metrics)")
assert.strictEqual(Model.prMeta(state.mine[0], nowMs), "glottologist · opened 2h ago · merged 10m ago")
assert.strictEqual(Model.prMeta(state.mine[1], nowMs), "glottologist · opened 1h ago")
assert.strictEqual(Model.prMeta(state.mine[2], nowMs), "glottologist · merged 5m ago")
assert.strictEqual(Model.prMeta(pr({ draft: true }), nowMs), "glottologist · opened 1h ago · draft")
assert.strictEqual(Model.prMeta(pr({ state: "closed" }), nowMs), "glottologist · opened 1h ago · closed")

assert.strictEqual(Model.stateLabel(state.mine[0]), "merged")
assert.strictEqual(Model.stateLabel(state.mine[1]), "open")
assert.strictEqual(Model.stateLabel(pr({ draft: true })), "draft")
assert.strictEqual(Model.stateLabel(pr({ state: "closed" })), "closed")
assert.notStrictEqual(Model.stateGlyph(state.mine[0]), Model.stateGlyph(state.mine[1]))

assert.strictEqual(Model.relativeTime(now, nowMs), "just now")
assert.strictEqual(Model.relativeTime(now - 90, nowMs), "1m ago")
assert.strictEqual(Model.relativeTime(now - 7200, nowMs), "2h ago")
assert.strictEqual(Model.relativeTime(now - 200000, nowMs), "2d ago")
assert.strictEqual(Model.relativeTime(0, nowMs), "")
assert.strictEqual(Model.relativeTime(now, NaN), "")

assert.strictEqual(Model.updatedText(now - 180, nowMs), "UPDATED 3M AGO")
assert.strictEqual(Model.updatedText(0, nowMs), "")
EOF

[ $? -eq 0 ] || fail "source-control model assertions"
echo "PASS source-control model"
