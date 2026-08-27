#!/usr/bin/env bats

setup() {
  TEST_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
  SCRIPT="$TEST_DIR/../unified-clipboard.sh"
  FAKE="$TEST_DIR/fake-hyprctl"
  export HYPRCTL="$FAKE"
  export FAKE_DISPATCH_LOG="$BATS_TEST_TMPDIR/dispatch.log"
  : >"$FAKE_DISPATCH_LOG"
  export FAKE_DISPATCH_STATUS=0
}

@test "GUI copy sends CTRL,C,activewindow" {
  export FAKE_WINDOW_JSON='{"class":"firefox","tags":["browser"]}'
  run "$SCRIPT" copy
  [ "$status" -eq 0 ]
  [ "$(cat "$FAKE_DISPATCH_LOG")" = "CTRL,C,activewindow" ]
}

@test "tagged terminal copy sends CTRL_SHIFT,C,activewindow" {
  export FAKE_WINDOW_JSON='{"class":"kitty","tags":["terminal"]}'
  run "$SCRIPT" copy
  [ "$status" -eq 0 ]
  [ "$(cat "$FAKE_DISPATCH_LOG")" = "CTRL_SHIFT,C,activewindow" ]
}

@test "GUI cut sends CTRL,X,activewindow" {
  export FAKE_WINDOW_JSON='{"class":"firefox","tags":["browser"]}'
  run "$SCRIPT" cut
  [ "$status" -eq 0 ]
  [ "$(cat "$FAKE_DISPATCH_LOG")" = "CTRL,X,activewindow" ]
}

@test "tagged terminal cut does not dispatch" {
  export FAKE_WINDOW_JSON='{"class":"kitty-dropterm","tags":["terminal"]}'
  run "$SCRIPT" cut
  [ "$status" -eq 0 ]
  [ ! -s "$FAKE_DISPATCH_LOG" ]
}

@test "GUI paste sends CTRL,V,activewindow" {
  export FAKE_WINDOW_JSON='{"class":"firefox","tags":["browser"]}'
  run "$SCRIPT" paste
  [ "$status" -eq 0 ]
  [ "$(cat "$FAKE_DISPATCH_LOG")" = "CTRL,V,activewindow" ]
}

@test "tagged terminal paste sends CTRL_SHIFT,V,activewindow" {
  export FAKE_WINDOW_JSON='{"class":"com.mitchellh.ghostty","tags":["terminal"]}'
  run "$SCRIPT" paste
  [ "$status" -eq 0 ]
  [ "$(cat "$FAKE_DISPATCH_LOG")" = "CTRL_SHIFT,V,activewindow" ]
}

@test "hyprctl dispatch failure is propagated" {
  export FAKE_WINDOW_JSON='{"class":"firefox","tags":["browser"]}'
  export FAKE_DISPATCH_STATUS=1
  run "$SCRIPT" copy
  [ "$status" -ne 0 ]
}

@test "unknown action exits non-zero" {
  run "$SCRIPT" bounce
  [ "$status" -ne 0 ]
}
