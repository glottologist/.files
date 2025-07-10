{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    lmstudio
    llm
    gorilla-cli
    claude-code
  ];
    home.file.".claude/CLAUDE.md".text = builtins.readFile ../../secrets/CLAUDE.md;

}
