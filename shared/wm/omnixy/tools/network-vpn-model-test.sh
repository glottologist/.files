#!/usr/bin/env bash
# VPN status helpers in the network Model.js.
set -uo pipefail
model="$(cd "$(dirname "$0")" && pwd)/../desktop/shell/plugins/panels/network/Model.js"
fail() { echo "FAIL $1"; exit 1; }
[ -f "$model" ] || fail "Model.js missing"

node --input-type=commonjs - "$model" <<'EOF'
const assert = require("assert")
const Model = require(process.argv[2])

// id, name, state, location -- as omnixy-network-vpn prints it.
const raw = [
  "mullvad\tMullvad\tconnected\tLondon, UK · gb-lon-wg-007",
  "proton\tProton VPN\tdisconnected\t",
  "",
  "torn line",
  "\tNameless\tconnected\t"
].join("\n")

const rows = Model.parseVpnStatus(raw)
assert.strictEqual(rows.length, 2, "blank, torn and id-less lines are dropped")

assert.deepStrictEqual(rows[0], {
  id: "mullvad",
  name: "Mullvad",
  state: "connected",
  location: "London, UK · gb-lon-wg-007"
})
assert.deepStrictEqual(rows[1], {
  id: "proton",
  name: "Proton VPN",
  state: "disconnected",
  location: ""
})

// A state the panel has no wording for reads as disconnected rather than
// leaking an unknown word into the row.
assert.strictEqual(Model.parseVpnStatus("mullvad\tMullvad\tbewildered\t")[0].state, "disconnected")

assert.deepStrictEqual(Model.parseVpnStatus(null), [])
assert.deepStrictEqual(Model.parseVpnStatus(""), [])

assert.strictEqual(Model.vpnStatusText(rows[0]), "Connected · London, UK · gb-lon-wg-007")
assert.strictEqual(Model.vpnStatusText(rows[1]), "Not connected")
assert.strictEqual(Model.vpnStatusText({ state: "connected", location: "" }), "Connected")
assert.strictEqual(Model.vpnStatusText({ state: "connecting", location: "Sweden" }), "Connecting… · Sweden")
assert.strictEqual(Model.vpnStatusText({ state: "disconnecting", location: "" }), "Disconnecting…")
assert.strictEqual(Model.vpnStatusText({ state: "error", location: "" }), "Blocked")
assert.strictEqual(Model.vpnStatusText(null), "")

// Anything holding the tunnel (or the firewall) counts as on, so the toggle's
// next press always releases it.
assert.strictEqual(Model.vpnIsActive("connected"), true)
assert.strictEqual(Model.vpnIsActive("connecting"), true)
assert.strictEqual(Model.vpnIsActive("error"), true)
assert.strictEqual(Model.vpnIsActive("disconnecting"), false)
assert.strictEqual(Model.vpnIsActive("disconnected"), false)

assert.strictEqual(Model.vpnToggleAction("connected"), "disconnect")
assert.strictEqual(Model.vpnToggleAction("error"), "disconnect")
assert.strictEqual(Model.vpnToggleAction("disconnected"), "connect")
EOF

[ $? -eq 0 ] || fail "network vpn model assertions"
echo "PASS network vpn model"
