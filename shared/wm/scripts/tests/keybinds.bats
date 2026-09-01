#!/usr/bin/env bats

setup() {
  TEST_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
  SCRIPT="$TEST_DIR/../keybinds.sh"
  FIXTURE="$TEST_DIR/fixtures/hyprctl-binds.txt"
  LUA_FIXTURE="$TEST_DIR/fixtures/hyprctl-binds-lua.txt"
  export HYPRCTL="$BATS_TEST_TMPDIR/hyprctl"
  export ROFI="$BATS_TEST_TMPDIR/rofi"
  export HYPRCTL_LOG="$BATS_TEST_TMPDIR/hyprctl.log"
  export ROFI_ARGS="$BATS_TEST_TMPDIR/rofi.args"
  export ROFI_INPUT="$BATS_TEST_TMPDIR/rofi.input"

  cat >"$HYPRCTL" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >>"$HYPRCTL_LOG"
[[ "${1:-}" == "binds" ]] || exit 90
cat "$KEYBIND_FIXTURE"
SH
  chmod +x "$HYPRCTL"

  cat >"$ROFI" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >"$ROFI_ARGS"
cat >"$ROFI_INPUT"
printf '%s\n' 'SUPER+RETURN  Terminal'
SH
  chmod +x "$ROFI"
  export KEYBIND_FIXTURE="$FIXTURE"
}

expected_catalog() {
  cat <<'EOF'
== Applications ==
SUPER+RETURN  Terminal

== Media ==
XF86AUDIOPLAY  Play or pause

== Other ==
SUPER+O  exec obsidian
SUPER+P  Lua action (details unavailable)

== Utilities ==
SUPER+CTRL+ALT+SHIFT+K  Keybindings

== Windows ==
ALT+TAB  Focus next window / Bring active window to top
SUPER+ALT+H  Swap window left
SUPER+MOUSE:272  Move window
EOF
}

@test "print mode emits the complete grouped and sorted catalog" {
  run "$SCRIPT" --print

  [ "$status" -eq 0 ]
  [ "$output" = "$(expected_catalog)" ]
  [ "$(cat "$HYPRCTL_LOG")" = "binds" ]
}

@test "aggregated Lua callbacks match separate Classic dispatcher records" {
  export KEYBIND_FIXTURE="$LUA_FIXTURE"
  run "$SCRIPT" --print

  [ "$status" -eq 0 ]
  [ "$output" = "$(expected_catalog)" ]
}

@test "normal mode is read-only and preserves prepared ordering" {
  run "$SCRIPT"

  [ "$status" -eq 0 ]
  [ "$(cat "$ROFI_INPUT")" = "$(expected_catalog)" ]
  grep -q -- '-no-sort' "$ROFI_ARGS"
  [ "$(cat "$HYPRCTL_LOG")" = "binds" ]
}

@test "unsupported arguments fail with usage" {
  run "$SCRIPT" --execute

  [ "$status" -eq 2 ]
  [[ "$output" == usage:* ]]
  [ ! -e "$HYPRCTL_LOG" ]
}
