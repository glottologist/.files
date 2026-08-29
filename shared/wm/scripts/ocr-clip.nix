{pkgs}:
pkgs.writeShellScriptBin "ocr-clip" ''
  set -euo pipefail
  img="$(${pkgs.coreutils}/bin/mktemp --suffix=.png)"
  trap '${pkgs.coreutils}/bin/rm -f "$img"' EXIT
  ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" "$img"
  ${pkgs.tesseract}/bin/tesseract "$img" stdout -l eng \
    | ${pkgs.wl-clipboard}/bin/wl-copy
  ${pkgs.libnotify}/bin/notify-send "OCR" "Text copied to clipboard"
''
