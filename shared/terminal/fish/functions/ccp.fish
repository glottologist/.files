function ccp
    set -lx CLAUDE_CONFIG_DIR $HOME/.claude-personal
    command claude $argv
end
