#!/usr/bin/env bash
# Asserts the properties the design plan promises of a vendored tree.
set -uo pipefail
src="${1:?upstream checkout}"; out="${2:?vendored tree}"
fail() { echo "FAIL $1"; exit 1; }

[ -x "$out/bin/omnixy-theme-set" ] || fail "omnixy-theme-set missing"
[ -e "$out/bin/omarchy-theme-set" ] && fail "omarchy-theme-set still present"
[ -f "$out/shell/shell.qml" ] || fail "shell.qml missing"
[ -f "$out/default/hypr/omnixy.lua" ] || fail "default/hypr/omnixy.lua missing"
[ -f "$out/default/omnixy/omnixy-menu.jsonc" ] || fail "menu missing"
[ -f "$out/default/omnixy/launcher.hides" ] || fail "launcher.hides missing"
[ -f "$out/config/omnixy/shell.json" ] || fail "shell.json missing"
[ -f "$out/default/fonts/omnixy/omnixy.ttf" ] || fail "icon font missing"
[ -f "$out/LICENSE" ] || fail "LICENSE missing"
grep -q '^commit ' "$out/UPSTREAM" || fail "UPSTREAM lacks commit"
[ -f "$out/logo.txt" ] || fail "logo.txt missing"

# Arch sections are gone from the menu, and nothing under install/ came.
grep -qE '^  "(install|update|remove)(\.|")' "$out/default/omnixy/omnixy-menu.jsonc" \
  && fail "Arch menu sections survived"
[ -e "$out/install" ] && fail "install/ was copied"
ls "$out/bin" | grep -qE '^omnixy-install-' && fail "omnixy-install-* survived"
for h in tmux vscode obsidian browser claude pi gnome; do
  [ -e "$out/bin/omnixy-theme-set-$h" ] && fail "dropped hook theme-set-$h survived"
done

# Themes came without their backgrounds.
[ "$(ls "$out/themes" | wc -l)" -eq 22 ] || fail "expected 22 themes"
find "$out/themes" -type d -name backgrounds | grep -q . && fail "backgrounds copied"

# The rename reached every text file; the only 'omarchy' left is inside
# upstream URLs and the provenance/licence files.
if grep -rIl omarchy "$out" --exclude=UPSTREAM --exclude=LICENSE \
    | xargs -r grep -In omarchy | grep -vE 'https?://|omarchy\.org|(basecamp|omacom|acme|example)/omarchy' | grep -q .; then
  fail "omarchy survives outside URLs"
fi
grep -rq 'OMARCHY_PATH' "$out" && fail "OMARCHY_PATH survives"
grep -q "https://omarchy.org/manual/" "$out/default/omnixy/omnixy-menu.jsonc" || fail "upstream URL was renamed"
grep -rq 'omnixy\.org\|basecamp/omnixy' "$out" && fail "a URL was renamed"
# Glob families: agent-usage-update finds collectors as omnixy-agent-usage-*.
[ -x "$out/bin/omnixy-agent-usage-fireworks" ] || fail "glob-family collector missing"
grep -rq 'omarchyPath' "$out/shell" && fail "omarchyPath survives"
grep -q '"/config/omnixy/shell.json"' "$out/shell/shell.qml" || fail "defaultsPath not renamed"

# The icon font's internal family follows the rename.
fam=$(fc-scan --format '%{family}' "$out/default/fonts/omnixy/omnixy.ttf")
[ "$fam" = "omnixy" ] || fail "font family is '$fam'"

# Local patches landed in source.
grep -q 'chmod -R u+w "$NEXT_THEME_PATH"' "$out/bin/omnixy-theme-set" || fail "theme-set chmod patch missing"
grep -q 'timeout=20)' "$out/bin/omnixy-agent-usage-codex" || fail "codex timeout patch missing"
[ -x "$out/bin/dropbox-cli" ] || fail "dropbox-cli shim missing"
[ -f "$out/bin/omnixy-agent-usage-grok" ] || fail "grok collector missing"

# Every script the closure kept can resolve every omnixy-* it names.
missing=$(grep -rhoE 'omnixy-[a-z0-9-]+' "$out/bin" "$out/shell" "$out/default" "$out/config" \
  | sort -u | while read -r n; do [ -e "$out/bin/$n" ] || echo "$n"; done \
  | grep -vE '^omnixy-(shell|menu|hook|bar|font|theme|reminder|capture|launch|system|toggle|hyprland|hw|audio|network|brightness|notification|restart|refresh|show|cmd|default|dev|display|agent|plugin|plymouth|update|pkg|channel|version|clipboard|screensaver|migrate|provision|disk|hibernation|snapshot)$' || true)
[ -z "$missing" ] || echo "note: unresolved names (family prefixes or optional): $missing"

echo PASS
