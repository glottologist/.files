#!/usr/bin/env bash
# Vendor the parts of upstream Omarchy that Omnixy runs, renamed to Omnixy.
#
#   vendor.sh <upstream-checkout> <output-dir>
#
# The output is the tree shared/wm/omnixy/package.nix builds. Running this
# against a newer upstream is how changes are taken from Omarchy: the
# closure, the cuts, the rename and the local patches are all recomputed,
# and UPSTREAM records what was vendored. Needs: bash, coreutils, findutils,
# grep, sed, jq, git (for the commit hash) and python3 with fontTools.
set -euo pipefail

src=$(realpath "${1:?upstream checkout}")
out=$(realpath -m "${2:?output directory}")
here=$(cd "$(dirname "$0")" && pwd)
omnixy=$(realpath "$here/..")

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cp -r "$src" "$work/src"
chmod -R u+w "$work/src"
src="$work/src"

# --- 1. Cut what Omnixy does not take -------------------------------------
#
# Arch package management (decision 2026-09-02-001) leaves the menu before
# the closure is computed, so nothing it reached is vendored by accident.
menu="$src/default/omarchy/omarchy-menu.jsonc"
grep -vE '^  "(install|update|remove)(\.|")' "$menu" > "$menu.cut"
# The row before the removed block ends with a comma; JSONC tolerates a
# trailing comma but the shell's parser strips only comments, so close it.
python3 - "$menu.cut" "$menu" <<'PY'
import re, sys
text = open(sys.argv[1]).read()
text = re.sub(r',(\s*\n\s*})', r'\1', text)
open(sys.argv[2], 'w').write(text)
PY
rm "$menu.cut"
# Every installer is Arch package management, whatever reaches it.
rm -f "$src/bin/omarchy-install-"*

# Post-theme hooks that write into files home-manager owns.
dropped_hooks=(theme-set-tmux theme-set-vscode theme-set-obsidian
               theme-set-browser theme-set-claude theme-set-pi theme-set-gnome)
for h in "${dropped_hooks[@]}"; do rm -f "$src/bin/omarchy-$h"; done
# omarchy-theme-set lists them by name; drop the lines so it does not fail.
for h in "${dropped_hooks[@]}"; do sed -i "/^  omarchy-$h$/d" "$src/bin/omarchy-theme-set"; done

# --- 2. Resolve the script closure -----------------------------------------
#
# Seeds: every omarchy-* name in the shell, the defaults, the Hyprland Lua
# and Omnixy's own module and bindings (which say omnixy-* once renamed, so
# both spellings seed). Then follow names transitively through bin/. Only
# names that exist as files are kept.
declare -A keep
queue=()
while read -r name; do
  [ -f "$src/bin/omarchy-$name" ] || continue
  keep[$name]=1; queue+=("$name")
done < <(grep -rhoE '(omarchy|omnixy)-[a-z0-9-]+' "$src/shell" "$src/config" "$src/default" \
           "$omnixy/default.nix" "$omnixy/bindings.lua" "$omnixy/bar" "$omnixy/Workspaces.qml" \
           | sed -E 's/^(omarchy|omnixy)-//' | sort -u)
while [ "${#queue[@]}" -gt 0 ]; do
  next=()
  for name in "${queue[@]}"; do
    while read -r dep; do
      [ -f "$src/bin/omarchy-$dep" ] || continue
      [ -n "${keep[$dep]:-}" ] && continue
      keep[$dep]=1; next+=("$dep")
    done < <(grep -ohE 'omarchy-[a-z0-9-]+' "$src/bin/omarchy-$name" | sed 's/^omarchy-//' | sort -u)
  done
  queue=("${next[@]}")
done
# Glob families: a kept script that lists omarchy-<prefix>-* (agent-usage-update
# does, for its collectors) needs every match, not just the names it spells
# out. The bare omarchy-* listings in the dev tools are not families.
for name in "${!keep[@]}"; do
  while read -r glob; do
    prefix=${glob%\*}; prefix=${prefix#omarchy-}
    [ -n "$prefix" ] || continue
    for f in "$src/bin/omarchy-$prefix"*; do
      [ -f "$f" ] || continue
      keep[$(basename "$f" | sed 's/^omarchy-//')]=1
    done
  done < <(grep -ohE 'omarchy-[a-z0-9-]*\*' "$src/bin/omarchy-$name" | sort -u)
done

# Which default/ subdirectories the closure reads, beyond hypr and omarchy.
declare -A defdirs
defdirs[hypr]=1; defdirs[omarchy]=1; defdirs[fonts]=1
for name in "${!keep[@]}"; do
  while read -r d; do defdirs[$d]=1; done < <(grep -ohE '\$OMARCHY_PATH/default/[a-z0-9_-]+' "$src/bin/omarchy-$name" | sed 's|.*/default/||' | sort -u)
done
# Scripts the shell reads by path are seeds already; the shell reads no
# default/ subdirectory but omarchy/.

# --- 3. Copy ---------------------------------------------------------------
rm -rf "$out"; mkdir -p "$out/bin" "$out/default" "$out/config" "$out/themes"
cp -r "$src/shell" "$out/shell"
for name in "${!keep[@]}"; do cp "$src/bin/omarchy-$name" "$out/bin/"; done
for d in "${!defdirs[@]}"; do [ -d "$src/default/$d" ] && cp -r "$src/default/$d" "$out/default/$d"; done
cp -r "$src/config/omarchy" "$out/config/omarchy"
rm -rf "$out/config/omarchy/hooks" "$out/config/omarchy/themed" "$out/config/omarchy/extensions"
for t in "$src"/themes/*/; do
  n=$(basename "$t"); mkdir -p "$out/themes/$n"
  find "$t" -mindepth 1 -maxdepth 1 ! -name backgrounds -exec cp -r {} "$out/themes/$n/" \;
done
cp "$src/LICENSE" "$src/logo.txt" "$src/icon.txt" "$out/"

# Local additions that are Omnixy's rather than upstream's.
cp "$here/dropbox-cli" "$out/bin/dropbox-cli"
cp "$here/agent-usage-grok.py" "$out/bin/omarchy-agent-usage-grok"
chmod +x "$out/bin/dropbox-cli" "$out/bin/omarchy-agent-usage-grok"

# --- 4. Local patches, applied before the rename so they read as upstream -
#
# Themes are staged by cp -r out of the read-only Nix store; make the
# staged tree writable or the next theme set cannot remove it.
sed -i 's|^rm -rf "\$NEXT_THEME_PATH"$|chmod -R u+w "$NEXT_THEME_PATH" 2>/dev/null \|\| true; rm -rf "$NEXT_THEME_PATH"|' "$out/bin/omarchy-theme-set"
sed -i 's|^# Generate dynamic configs$|chmod -R u+w "$NEXT_THEME_PATH"|' "$out/bin/omarchy-theme-set"
sed -i 's|^rm -rf "\$CURRENT_THEME_PATH"$|chmod -R u+w "$CURRENT_THEME_PATH" 2>/dev/null \|\| true; rm -rf "$CURRENT_THEME_PATH"|' "$out/bin/omarchy-theme-set"
# The Codex rate-limit call takes close to four seconds on this network.
sed -i 's|"account/rateLimits/read", timeout=4)|"account/rateLimits/read", timeout=20)|' "$out/bin/omarchy-agent-usage-codex"

# --- 5. Rename ---------------------------------------------------------------
#
# Text first, then paths, deepest first. Binary files are left alone; the
# icon font is handled below. URL spans are skipped: a renamed upstream link
# (omarchy.org, github.com/basecamp/omarchy, the example plugin repos) is a
# dead one.
mapfile -t textfiles < <(grep -rIl -e omarchy -e Omarchy -e OMARCHY "$out" || true)
python3 - "${textfiles[@]}" <<'PY'
import re, sys
# Protected spans: URLs, scheme-less omarchy.org hostnames, and upstream
# repository slugs (gh --repo basecamp/omarchy, example plugin repos).
url = re.compile(r"https?://[^\s\"'<>)\]]+"
                 r"|[A-Za-z0-9.-]*omarchy\.org\b[^\s\"'<>)\]]*"
                 r"|\b(?:basecamp|omacom|acme|example)/omarchy[A-Za-z0-9._-]*")
def rename(s):
    return (s.replace("OMARCHY_PATH", "OMNIXY_PATH").replace("omarchyPath", "omnixyPath")
             .replace("OMARCHY", "OMNIXY").replace("Omarchy", "Omnixy").replace("omarchy", "omnixy"))
for path in sys.argv[1:]:
    text = open(path, encoding="utf-8", errors="surrogateescape").read()
    out, last = [], 0
    for m in url.finditer(text):
        out.append(rename(text[last:m.start()])); out.append(m.group(0)); last = m.end()
    out.append(rename(text[last:]))
    open(path, "w", encoding="utf-8", errors="surrogateescape").write("".join(out))
PY
find "$out" -depth -name '*omarchy*' | while read -r p; do
  mv "$p" "$(dirname "$p")/$(basename "$p" | sed 's/omarchy/omnixy/g')"
done

# The font's family name lives inside the TTF; the menu selects it by name.
python3 - "$out/default/fonts/omnixy/omnixy.ttf" <<'PY'
import sys
from fontTools.ttLib import TTFont
f = TTFont(sys.argv[1])
for rec in f["name"].names:
    s = rec.toUnicode()
    if "marchy" in s.lower():
        rec.string = s.replace("Omarchy", "Omnixy").replace("omarchy", "omnixy")
f.save(sys.argv[1])
PY

# --- 6. Provenance -----------------------------------------------------------
commit=$(git -C "${1}" rev-parse HEAD 2>/dev/null \
  || jq -r '.nodes.omarchy.locked.rev // empty' "$omnixy/../../../flake.lock" 2>/dev/null)
commit=${commit:-"unknown (source was not a git checkout and flake.lock has no omarchy node)"}
cat > "$out/UPSTREAM" <<EOF
Vendored from https://github.com/omacom/omarchy by shared/wm/omnixy/tools/vendor.sh
tag     v$(cat "$src/version" 2>/dev/null || echo unknown)
commit  $commit
date    $(date -I)
scripts ${#keep[@]}
cuts    menu sections install.* update.* remove.*; hooks ${dropped_hooks[*]}; themes/*/backgrounds; install/ migrations/ applications/ manual/ docs/ test/
rename  omarchy->omnixy (paths, scripts, the path variable and plugin property, widget ids, font family); upstream URLs and repository slugs preserved
EOF
echo "vendored ${#keep[@]} scripts into $out"
