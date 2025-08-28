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
  home.file.".claude/commands/pr.md".text = builtins.readFile ../../secrets/claude/commands/pr.md;
}
