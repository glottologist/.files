{
  config,
  pkgs,
  claude-code-nix,
  ...
}: {
  home.packages = with pkgs; [
    lmstudio
    llm
    gorilla-cli
    claude-code-nix.packages.${system}.default
  ];
  home.file.".claude/CLAUDE.md".text = builtins.readFile ../../secrets/claude/CLAUDE.md;
  home.file.".claude/commands/audit.md".text = builtins.readFile ../../secrets/claude/commands/audit.md;
  home.file.".claude/commands/document.md".text = builtins.readFile ../../secrets/claude/commands/document.md;
  home.file.".claude/commands/explain.md".text = builtins.readFile ../../secrets/claude/commands/explain.md;
  home.file.".claude/commands/fix.md".text = builtins.readFile ../../secrets/claude/commands/fix.md;
  home.file.".claude/commands/pr.md".text = builtins.readFile ../../secrets/claude/commands/pr.md;
}
