function cxw --description "Codex work profile"
    set -lx CODEX_HOME "$HOME/.codex-work"
    command mkdir -p -m 700 -- "$CODEX_HOME"; or return
    command codex $argv
end
