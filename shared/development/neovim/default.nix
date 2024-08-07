{ config, lib, pkgs, ... }:

let
  custom-plugins = pkgs.callPackage ./plugins.nix {
    inherit (pkgs.vimUtils) buildVimPlugin;
  };

  plugins =   custom-plugins // pkgs.vimPlugins;

  overriddenPlugins = with pkgs; [];

  vimPlugins = with plugins; [
                            # earthly-vim             # Vim support for Eartly ci
    Coqtail                 # Interactive Coq proofs in Vim
    agda-vim                # Vim mode for editing AGDA
    ansible-vim             # Vim syntax plugin for Ansible
    aurora                  # A 24-bit dark theme
    ayu-vim                 # Simple, bright and elegant vim theme
    barbar-nvim             # Tabline plugin with re-orderable, auto-sizing, clickable tabs, icons, nice highlighting, sort-by commands and a magic jump-to-buffer mode.
    calendar                # Vim  calendar
    coc-clangd              # C/C++/Objective-C  completion
    coc-clap
    coc-cmake               # Cmake completion
    coc-css                 # Css completion
    coc-denite
    coc-docker
    coc-emmet               # Emmet LS
    coc-eslint
    coc-explorer
    coc-flutter
    coc-fzf                 # Use FZF instead of coc.nvim built-in fuzzy finder.
    coc-git                 # Git integration for coc.nvim
    coc-go                  # Go lang server
    coc-haxe
    coc-highlight
    coc-html                # Html language extension
    coc-java                # Fork of vscode-java to work with coc.nvim
    coc-jest
    coc-json                # Json language server extension for coc.nvim
    coc-lists
    coc-lua                 # Lua language server extension
    coc-markdownlint        # Linting coc extension for vim
    coc-marketplace
    coc-metals              # PLUGIN: Scala LSP client for CoC
    coc-neco
    coc-nginx
    coc-nvim                # LSP client + autocompletion plugin
    coc-pairs               # Autopair functionality for vim
    coc-prettier            # Prettier is an opinionated code formatter
    coc-pyright
    coc-python
    coc-r-lsp               # R LSP Client for coc.nvim, powered by the R Language Server.
    coc-rls
    coc-sh                  # Bash language completion
    coc-smartf
    coc-snippets            # Code snippets extension
    coc-spell-checker       # A basic spell checker that works well with camelCase code.
    coc-sqlfluff
    coc-stylelint
    coc-svelte
    coc-tabnine             # All language auto completion
    coc-texlab
    coc-toml
    coc-tslint
    coc-tslint-plugin       # Typescript language server linter plugin
    coc-tsserver            # TYpescript language server
    coc-ultisnips
    coc-vetur
    coc-vimlsp              # Vim language server extension
    coc-vimtex              # Coc support for vimtex
    coc-wxml
    coc-yaml                # Yaml language server support
    coc-yank                # yank plugin for CoC
    copilot-vim             # GitHub Copilot uses OpenAI Codex to suggest code and entire functions in real-time right from your editor.
    csv                     # csv file handling in vim
    ctrlsf-vim              # edit file in place after searching with ripgrep
    elm-vim                 # Elm LS
    emmet-vim               # Emmet abbreviations syntax support
    fzf-hoogle              # search hoogle with fzf
    fzf-vim                 # fuzzy finder
    goyo                    # Distraction free writing - Zen Mode
    gundo-vim               # Gundo.vim is Vim plugin to visualize your Vim undo tree.
    idris-vim               # This is an Idris mode for vim which features syntax highlighting, indentation and optional syntax checking via Syntastic.
    idris2-vim              # This is an Idris2 mode for vim which features interactive editing, syntax highlighting, indentation and optional syntax checking via Syntastic.
    jq-vim                  # Syntax highlighting for jq script files
    julia-vim               # Julia support for Vim
    kotlin-vim              # Kotlin suport in vim
    latex-box               # LAtex language support
    latex-live-preview      # This plugin provides a live preview of the output PDF of your LaTeX file.
    lightline-vim           # configurable status line (can be used by coc)
    ligo-vim                # Manually packaged new ligo vim plugin
    markdown-preview-nvim   # Preview markdown on your modern browser with synchronised scrolling and flexible configuration
    material-vim            # modern theme with true colors support
    neomake                 # run programs asynchronously and highlight errors
    nerdcommenter           # code commenter
    nerdtree                # tree explorer
    nerdtree-git-plugin     # shows files git status on the NerdTree
    nvim-dap
    nvim-web-devicons       # A lua fork of vim-devicons.
    nvim-whichkey-setup-lua # This nvim-plugin is just a wrapper for vim-which-key to simplify setup in lua.
    oceanic-material        # A dark colorscheme for vim/neovim
    papercolor-theme        # Light & Dark color schemes for terminal and GUI Vim awesome editor
    plenary-nvim            # Lua functions package
    purescript-vim          # Purescript language support for vim and neovim providing syntax highlighting and indentation based on based on idris-vim and haskell-vim.
    quickfix-reflector-vim  # make modifications right in the quickfix window
    rainbow_parentheses-vim # for nested parentheses
    salt-vim
    sqlite-lua
    syntastic               # Syntax checker for languages
    tagbar                  # Tagbar is a Vim plugin that provides an easy way to browse the tags of the current file and get an overview of its structure.
    taglist-vim
    telescope-coc-nvim
    telescope-lsp-handlers-nvim
    telescope-nvim
    telescope-symbols-nvim
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
    vim-fugitive            # Fugitive is the premier Vim plugin for Git.
    vim-gist                # This is a vimscript for creating gists
    vim-gitgutter
    vim-gtfo
    vim-hdevtools           # Type assistence for Haskell
    vim-hoogle              # This plugin query hoogle for you and display the results in a special window.
    vim-nix
    vim-pandoc
    vim-pandoc-syntax       # Pandoc syntax highlighting for Markdown
    vim-repeat              # repeat plugin commands with (.)
    vim-scala               # scala plugin
    vim-shellcheck          # Shellcheck plugin
    vim-snippets
    vim-solidity            # Solidity syntax
    vim-surround            # quickly edit surroundings (brackets, html tags, etc)
    vim-tmux                # syntax highlighting for tmux conf file and more
    vim-which-key
    vimRipgrep              # blazing fast search using ripgrep
    vimfstar
    vimtex                  # LaTex syntax plugin
    zk-nvim                 # zk plugin
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

  # neovim-6 nightly stuff
  neovim-6     = pkgs.callPackage ./dev/nightly_6.nix {};
  nvim6-config = builtins.readFile ./dev/metals.vim;
  new-plugins  = pkgs.callPackage ./dev/plugins.nix {
    inherit (pkgs.vimUtils) buildVimPlugin;
    inherit (pkgs) fetchFromGitHub;
  };
  #nvim6-plugins = with new-plugins; [
    #completion-nvim
    #diagnostic-nvim
    #nvim-lsp
    #nvim-metals
  #];
in
{
  programs.neovim = {
    enable       = true;
    extraConfig  = vimConfig;
    #package      = neovim-6;
    plugins      = vimPlugins;
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
