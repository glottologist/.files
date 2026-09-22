#!/usr/bin/env bash
# Settings and folder-browser helpers in the Dropbox panel's Model.js.
set -uo pipefail
model="$(cd "$(dirname "$0")" && pwd)/../desktop/shell/plugins/panels/dropbox/Model.js"
fail() { echo "FAIL $1"; exit 1; }
[ -f "$model" ] || fail "Model.js missing"

node --input-type=commonjs - "$model" <<'JS'
const assert = require("assert")
const Model = require(process.argv[2])

const status = Model.parseStatus(JSON.stringify({
  ok: true, installed: true, running: true, authenticated: true,
  accountPath: "/h/Team/Me", rootPath: "/h/Team",
  excluded: ["/h/Team/Me/COMICS"],
  bandwidth: { known: true, downloadMode: "unlimited", uploadMode: "auto", downloadLimit: "50", uploadLimit: 10 },
  lanSync: false, lanSyncRecorded: true,
  autostart: { managed: "systemd", enabled: true }
}))
assert.deepStrictEqual(status.excluded, ["/h/Team/Me/COMICS"])
assert.deepStrictEqual(status.bandwidth, { known: true, downloadMode: "unlimited", uploadMode: "auto", downloadLimit: 50, uploadLimit: 10 })
assert.strictEqual(status.lanSync, false)
assert.strictEqual(status.lanSyncRecorded, true)
assert.deepStrictEqual(status.autostart, { managed: "systemd", enabled: true })
assert.strictEqual(status.rootPath, "/h/Team")

const legacy = Model.parseStatus(JSON.stringify({ ok: true, accountPath: "/h/Dropbox", files: [] }))
assert.deepStrictEqual(legacy.excluded, [])
assert.strictEqual(legacy.bandwidth.known, false)
assert.strictEqual(legacy.bandwidth.downloadMode, "unlimited")
assert.strictEqual(legacy.lanSync, true)
assert.strictEqual(legacy.lanSyncRecorded, false)
assert.deepStrictEqual(legacy.autostart, { managed: "desktop", enabled: false })
assert.strictEqual(legacy.rootPath, "/h/Dropbox")

assert.strictEqual(Model.normaliseBandwidth({ downloadMode: "bogus", uploadMode: "bogus", downloadLimit: -3 }).downloadMode, "unlimited")
assert.strictEqual(Model.normaliseBandwidth({ uploadMode: "manual" }).uploadMode, "manual")

assert.strictEqual(Model.bandwidthLabel("unlimited", 50), "Unlimited")
assert.strictEqual(Model.bandwidthLabel("auto", 50), "Auto")
assert.strictEqual(Model.bandwidthLabel("manual", 50), "50 KB/s")
assert.strictEqual(Model.bandwidthLabel("manual", 1500), "1.5 MB/s")
assert.strictEqual(Model.bandwidthLabel("manual", 12000), "12 MB/s")
assert.strictEqual(Model.bandwidthLabel("manual", 0), "Unlimited")

assert.deepStrictEqual(Model.throttleArgs({ downloadMode: "unlimited", uploadMode: "auto" }), ["unlimited", "auto"])
assert.deepStrictEqual(Model.throttleArgs({ downloadMode: "manual", downloadLimit: 500, uploadMode: "manual", uploadLimit: 100 }), ["500", "100"])
assert.deepStrictEqual(Model.throttleArgs({ downloadMode: "manual", downloadLimit: 0, uploadMode: "manual", uploadLimit: 0 }), ["unlimited", "unlimited"])
assert.deepStrictEqual(Model.throttleArgs(null), ["unlimited", "unlimited"])

assert.strictEqual(Model.nextUploadMode("unlimited"), "auto")
assert.strictEqual(Model.nextUploadMode("auto"), "manual")
assert.strictEqual(Model.nextUploadMode("manual"), "unlimited")
assert.strictEqual(Model.nextUploadMode("bogus"), "unlimited")

const folders = Model.parseFolders(JSON.stringify({ ok: true, path: "/h/Team/Me", rootPath: "/h/Team", folders: [{ name: "COMICS", path: "/h/Team/Me/COMICS", excluded: true, excludedInside: 0 }] }))
assert.strictEqual(folders.ok, true)
assert.strictEqual(folders.folders.length, 1)
assert.strictEqual(Model.parseFolders("").ok, false)
assert.strictEqual(Model.parseFolders("nope").ok, false)
assert.strictEqual(Model.parseFolders(JSON.stringify({ ok: false, error: "Folder is outside Dropbox" })).error, "Folder is outside Dropbox")

assert.strictEqual(Model.relativeFolder("/h/Team", "/h/Team"), "/")
assert.strictEqual(Model.relativeFolder("/h/Team/Me/BOOKS", "/h/Team"), "/Me/BOOKS")
assert.strictEqual(Model.relativeFolder("/elsewhere", "/h/Team"), "/elsewhere")
assert.strictEqual(Model.relativeFolder("/h/Team", ""), "/")

assert.strictEqual(Model.parentPath("/h/Team/Me/BOOKS", "/h/Team"), "/h/Team/Me")
assert.strictEqual(Model.parentPath("/h/Team/Me", "/h/Team"), "/h/Team")
assert.strictEqual(Model.parentPath("/h/Team", "/h/Team"), "/h/Team")
assert.strictEqual(Model.parentPath("", "/h/Team"), "/h/Team")

assert.strictEqual(Model.folderMeta({ excluded: true }), "Not synced")
assert.strictEqual(Model.folderMeta({ excluded: false, excludedInside: 4 }), "Synced · 4 excluded inside")
assert.strictEqual(Model.folderMeta({ excluded: false, excludedInside: 0 }), "Synced")
assert.strictEqual(Model.folderMeta(null), "")

console.log("ok")
JS
