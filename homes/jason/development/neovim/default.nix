{ config, lib, pkgs, ... }:

let
  custom-plugins = pkgs.callPackage ./plugins.nix {
    inherit (pkgs.vimUtils) buildVimPlugin;
  };

  plugins = pkgs.vimPlugins  // custom-plugins;

  overriddenPlugins = with pkgs; [];

  myVimPlugins = with plugins; [
    aurora
    ayu-vim
    agda-vim
    ansible-vim
    barbar-nvim
    calendar
    coc-clangd              #  C/C++/Objective-C  completion
    coc-cmake
    coc-css
    coc-elixir
    coc-emmet               # Emmet LS
    coc-fzf
    coc-git
    coc-go                  # Go lang server
    coc-html
    coc-java
    coc-json                # Json LS
    coc-lua
    coc-markdownlint
    coc-metals              # Scala LSP client for CoC
    coc-nvim                # LSP client + autocompletion plugin
    coc-prettier
    coc-pyright
    coc-python
    coc-r-lsp
    coc-rust-analyzer       # Rust language completion
    coc-sh                  # Bash language completion
    coc-spell-checker
    coc-tsserver            # TYpescript language server
    coc-tslint-plugin            # TYpescript language server linter plugin
    coc-vimlsp
    coc-vimtex
    coc-yaml
    coc-yank                # yank plugin for CoC
    Coqtail
    csv
    ctrlsf-vim              # edit file in place after searching with ripgrep
    elm-vim
    emmet-vim
    flattened
    fzf-vim                 # fuzzy finder
    fzf-hoogle              # search hoogle with fzf
    fugitive
    Gist
    #gitgutter
    goyo
    Gundo
    Hoogle
    idris-vim
    idris2-vim
    jq-vim
    julia-vim
    kotlin-vim
    latex-box
    latex-live-preview
    lightline-vim           # configurable status line (can be used by coc)
    markdown-preview-nvim
    material-vim            # modern theme with true colors support
    neomake                 # run programs asynchronously and highlight errors
    nerdcommenter           # code commenter
    nerdtree                # tree explorer
    nerdtree-git-plugin     # shows files git status on the NerdTree
    neuron-vim
    nvim-web-devicons
    oceanic-material
    papercolor-theme
    purescript-vim
    quickfix-reflector-vim  # make modifications right in the quickfix window
    rainbow_parentheses-vim # for nested parentheses
    salt-vim
    sqlite-lua
    syntastic           # Syntax checker for languages
    Tagbar
    taglist-vim
    #telescopenvim
    #telescope-symbols-nvim
    tender-vim
    vim-airline
    vim-airline-themes
    vim-css-color
    vim-devicons
    vim-easy-align
    vim-easymotion
    vim-fish
    vim-fsharp
    vim-fugitive
    vim-gtfo
    vim-hdevtools           # Type assistence for Haskell
    vim-nix
    vim-pandoc-syntax       # Pandoc syntax highlighting for Markdown
    vim-pandoc
    vim-repeat              # repeat plugin commands with (.)
    vim-ripgrep             # blazing fast search using ripgrep
    vim-scala               # scala plugin
    vim-shellcheck          # Shellcheck plugin
    vim-snippets
    vim-solidity            # Solidity syntax
    vim-surround            # quickly edit surroundings (brackets, html tags, etc)
    vim-snippets
    vim-tmux                # syntax highlighting for tmux conf file and more
    vim-which-key
    vimfstar
    nvim-whichkey-setup-lua
  ] ++ overriddenPlugins;

  baseConfig    = builtins.readFile ./config.vim;
  languageConfig     = builtins.readFile ./language.vim;
  markdownConfig     = builtins.readFile ./markdown.vim;
  cocSettings   = builtins.toJSON (import ./coc-settings.nix);
  whichkeyLua = builtins.readFile ./whichkey.lua;
  pluginsConfig = builtins.readFile ./plugins.vim;
  zenConfig = builtins.readFile ./zen.vim;
  gitConfig = builtins.readFile ./git.vim;
  tagConfig = builtins.readFile ./tag.vim;
  keyConfig = builtins.readFile ./whichkey.vim;
  vimConfig     = baseConfig + zenConfig +  pluginsConfig + markdownConfig +  languageConfig + keyConfig + gitConfig + tagConfig;

  # neovim-5 nightly stuff
  neovim-5     = pkgs.callPackage ./dev/nightly.nix {};
  nvim5-config = builtins.readFile ./dev/metals.vim;
  new-plugins  = pkgs.callPackage ./dev/plugins.nix {
    inherit (pkgs.vimUtils) buildVimPlugin;
    inherit (pkgs) fetchFromGitHub;
  };
  nvim5-plugins = with new-plugins; [
    completion-nvim
    diagnostic-nvim
    nvim-lsp
    nvim-metals
  ];
in
{
  programs.neovim = {
    enable       = true;
    extraConfig  = vimConfig;
    package      = neovim-5;
    plugins      = myVimPlugins;
    viAlias      = true;
    vimAlias     = true;
    vimdiffAlias = true;
    withNodeJs   = true; # for coc.nvim
    withPython3  = true; # for plugins
  };

  xdg.configFile = {
    "nvim/coc-settings.json".text = cocSettings;
    "nvim/lua/whichkey.lua".text = whichkeyLua;
  };
}
