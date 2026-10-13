#!/usr/bin/env bash
# Exercise the real QML service while the bus name precedes the native interface.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
radio_source=${RADIO_SOURCE:-"$here/../desktop/shell/plugins/panels/media-radio"}
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin" "$work/runtime"
chmod 700 "$work/runtime"
cp "$radio_source/Model.js" "$radio_source/Service.qml" "$work/"
export RADIO_TEST_DIR="$work"

cat > "$work/bin/systemctl" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
[[ "$*" == "--user start omnixy-radio.service" ]]
echo start >> "$RADIO_TEST_DIR/starts"
SH

cat > "$work/bin/busctl" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
if [[ " $* " == *" NameHasOwner "* ]]; then
  echo '{"type":"b","data":[true]}'
  exit 0
fi
count=0
[[ ! -f "$RADIO_TEST_DIR/reads" ]] || read -r count < "$RADIO_TEST_DIR/reads"
if [[ " $* " == *" List "* ]]; then
  count=$((count + 1))
  echo "$count" > "$RADIO_TEST_DIR/reads"
fi
if (( count < 8 )); then
  echo 'Call failed: No such interface “io.gitlab.Goodvibes.Stations” on object at path /io/gitlab/Goodvibes' >&2
  exit 1
fi
[[ " $* " == *" --auto-start=no "* ]]
if [[ " $* " == *" List "* ]]; then
  if [[ -f "$RADIO_TEST_DIR/adds" ]]; then
    echo '{"type":"aa{sv}","data":[[{"uri":{"type":"s","data":"https://example.invalid/radio"},"name":{"type":"s","data":"Gàidheal"}}]]}'
  else
    echo '{"type":"aa{sv}","data":[[]]}'
  fi
elif [[ " $* " == *" Add "* ]]; then
  printf '%s\n' "$*" >> "$RADIO_TEST_DIR/adds"
else
  exit 1
fi
SH
chmod +x "$work/bin/systemctl" "$work/bin/busctl"

cat > "$work/shell.qml" <<'QML'
import QtQuick
import Quickshell

ShellRoot {
  id: test
  property int ticks: 0

  function fail(message) {
    console.error("FAIL " + message)
    Qt.quit()
  }

  Service { id: radio }

  Component.onCompleted: {
    radio.addStation("https://example.invalid/radio", "Gàidheal")
  }

  Timer {
    interval: 100
    repeat: true
    running: true
    onTriggered: {
      test.ticks++
      if (radio.lastError) {
        test.fail(radio.lastError)
        return
      }
      if (test.ticks === 3) {
        if (!radio.busy || radio.running) {
          test.fail("the service must stay busy until its native interface is ready")
          return
        }
        radio.addStation("https://example.invalid/duplicate", "duplicate")
        radio.refresh()
      }
      if (radio.running && !radio.busy && radio.stations.length === 1) {
        if (radio.stations[0].name !== "Gàidheal" || radio.listError) {
          test.fail("the queued add must refresh the library without an error")
          return
        }
        radio.startDaemon()
        console.log("PASS media-radio startup")
        Qt.quit()
      } else if (test.ticks >= 60) {
        test.fail("the queued add never completed")
      }
    }
  }
}
QML

if ! PATH="$work/bin:$PATH" XDG_RUNTIME_DIR="$work/runtime" XDG_CACHE_HOME="$work/cache" QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME=generic \
  timeout 10 "${QUICKSHELL:-quickshell}" --no-color -p "$work" > "$work/log" 2>&1; then
  cat "$work/log"
  exit 1
fi
if ! grep -q 'PASS media-radio startup' "$work/log" || grep -Eq 'FAIL|TypeError|ReferenceError' "$work/log"; then
  cat "$work/log"
  exit 1
fi
[[ $(wc -l < "$work/starts") -eq 1 ]]
[[ $(wc -l < "$work/adds") -eq 1 ]]
if grep -q duplicate "$work/adds"; then
  echo "FAIL duplicate add during startup"
  exit 1
fi
echo "PASS media-radio startup"
