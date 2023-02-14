{ pkgs, ...}:
{
  home.packages = with pkgs; [
  nodePackages.typescript
  nodePackages.typescript-language-server
  nodePackages.ts-node
  nodePackages.coc-tsserver  # tsserver extension for coc.nvim
  nodePackages.coc-tslint-plugin  # tslint plugin extension for coc.nvim
  rslint


];

  home.sessionVariables = {
    PATH = ["$HOME/.npm-packages/bin"];
  };

}
