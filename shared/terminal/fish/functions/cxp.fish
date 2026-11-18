function cxp --description "Codex personal profile"
    set -lx CODEX_HOME "$HOME/.codex-personal"
    command mkdir -p -m 700 -- "$CODEX_HOME"; or return
    command codex $argv
end
