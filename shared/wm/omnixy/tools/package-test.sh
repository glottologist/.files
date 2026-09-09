#!/usr/bin/env bash
set -uo pipefail
fail() { echo "FAIL $1"; exit 1; }
out=$(nix build --no-link --print-out-paths --impure --expr '
  let pkgs = import <nixpkgs> {};
  in pkgs.callPackage ./shared/wm/omnixy/package.nix { codexbar = pkgs.hello; }' 2>&1 | tail -1)
[ -d "$out/bin" ] || fail "build failed: $out"
[ -x "$out/bin/omnixy-theme-set" ] || fail "omnixy-theme-set missing"
[ -x "$out/bin/omnixy-pkg-present" ] || fail "pkg-present resolver missing"
[ -x "$out/bin/omnixy-update-available" ] || fail "update-available missing"
[ -x "$out/bin/omnixy-plymouth-set" ] || fail "plymouth stub missing"
grep -q "not changed at runtime" "$out/bin/omnixy-plymouth-set" || fail "plymouth is not a stub"
[ -x "$out/bin/uwsm-app" ] || fail "uwsm-app missing"
[ -x "$out/bin/ttfx" ] || fail "ttfx shim missing"
"$out/bin/ttfx" --version 2>&1 | grep -q "TerminalTextEffects" || fail "ttfx shim does not run"
[ -x "$out/bin/omnixy-network-speedtest-record" ] || fail "speedtest recorder missing"
[ -n "$(XDG_STATE_HOME=$(mktemp -d) "$out/bin/omnixy-network-speedtest-record" --history 2>&1)" ] \
  && fail "speedtest recorder reports something with no history"
XDG_STATE_HOME=$(mktemp -d) "$out/bin/omnixy-network-speedtest-record" --nonsense 2>/dev/null \
  && fail "speedtest recorder accepts an unknown argument"
grep -q "$(nix eval --raw --impure --expr '(import <nixpkgs> {}).hello')/bin/codexbar" "$out/bin/omnixy-agent-usage-grok" || fail "codexbar not substituted"
grep -q '@codexbar@' "$out/bin/omnixy-agent-usage-grok" && fail "placeholder survived"
head -1 "$out/bin/omnixy-menu" | grep -q '^#!/nix/store' || fail "shebangs not patched"
[ -f "$out/config/omnixy/shell.json" ] || fail "shell.json missing"
[ -f "$out/default/omnixy/omnixy-menu.jsonc" ] || fail "menu missing"
nix eval --impure --expr 'let pkgs = import <nixpkgs> {}; in (pkgs.callPackage ./shared/wm/omnixy/package.nix { codexbar = pkgs.hello; }).runtimePath' --raw | grep -q vips || fail "runtimePath lacks vips"
echo PASS
