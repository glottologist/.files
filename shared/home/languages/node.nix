{pkgs, ...}: {
  home.packages = with pkgs; [
    nodejs # Event-driven I/O framework for the V8 JavaScript engine
    node2nix # Generate Nix expressions to build NPM packages
    nodePackages.asar # Creating Electron app packages
    nodePackages.bash-language-server # A language server for Bash
    nodePackages.bower # The browser package manager
    nodePackages.bower2nix # Generate nix expressions to fetch bower dependencies
    nodePackages.browser-sync # Live CSS Reload & Browser Syncing
    nodePackages.coc-clangd # clangd extension for coc
    nodePackages.coc-cmake # cmake extension for coc
    nodePackages.coc-css # css extension for coc
    nodePackages.coc-docker # docker extension for coc
    nodePackages.coc-emmet # emmet extension for coc
    nodePackages.coc-eslint # eslint extension for coc
    nodePackages.coc-flutter # flutter extension for coc
    nodePackages.coc-git # git extension for coc
    nodePackages.coc-go # go extension for coc
    nodePackages.coc-java # java extension for coc
    nodePackages.coc-json # json extension for coc
    nodePackages.coc-lists # :w lists extension for coc
    nodePackages.coc-markdownlint # markdownlint extension for coc
    nodePackages.coc-pairs # auto pairs extension for coc
    nodePackages.coc-prettier # prettier extension for coc
    nodePackages.coc-pyright # pyright extension for coc
    nodePackages.coc-r-lsp # r-lsp extension for coc
    nodePackages.coc-sh # sh extension for coc
    nodePackages.coc-smartf # smartf extension for coc
    nodePackages.coc-snippets # snippets extension for coc
    nodePackages.coc-tabnine # tabnine extension for coc
    nodePackages.coc-texlab # texlab extension for coc
    nodePackages.coc-toml # toml extension for coc
    nodePackages.coc-vetur # vetur extension for coc
    nodePackages.coc-vimlsp # vimlsp extension for coc
    nodePackages.coc-vimtex # vimtex extension for coc
    nodePackages.coc-yaml # yaml extension for coc
    nodePackages.coc-yank # yank extension for coc
    nodePackages.coffee-script # Unfancy JavaScript
    nodePackages.cordova # Cordova command line interface tool
    nodePackages.create-react-app # Create React apps with no build configuration.
    nodePackages.create-react-native-app # Create React Native apps with no build configuration
    nodePackages.csslint # CSSLint
    nodePackages.esy # Package builder for esy.
    nodePackages.fx # Command-line JSON viewer
    nodePackages.ganache # A library and cli to create a local blockchain for fast Ethereum development.
    nodePackages.gatsby-cli # Gatsby command-line interface for creating new sites and running Gatsby commands
    nodePackages.gulp # The streaming build system.
    #nodePackages.gulp-cli                   # Command line interface for gulp
    nodePackages.js-yaml # YAML 1.2 parser and serializer
    nodePackages.jsonlint # Validate JSON
    nodePackages.karma # Spectacular Test Runner for JavaScript.
    nodePackages.live-server # simple development http server with live reload capability
    nodePackages.livedown # Live Markdown previews for your favourite editor.
    nodePackages.lua-fmt # Format Lua code
    nodePackages.mermaid-cli # Command-line interface for mermaid
    nodePackages.mocha # simple, flexible, fun test framework
    nodePackages.near-cli # General purpose command line tools for interacting with NEAR Protocol
    nodePackages.nijs # An internal DSL for the Nix package manager in JavaScript
    nodePackages.npm # a package manager for JavaScript
    nodePackages.nrm # NPM registry manager can help you easy and fast switch between different npm registries, now include: cnpm, taobao, nj(nodejitsu), edunpm
    nodePackages.orval # A swagger client generator for typescript
    nodePackages.pkg # Package your Node.js project into an executable
    nodePackages.pnpm # Fast, disk space efficient package manager
    nodePackages.prettier # Prettier is an opinionated code formatter
    nodePackages.pscid # A lightweight editor experience for PureScript development
    nodePackages.pulp # A build system for PureScript projects
    nodePackages.react-static # A progressive static site generator for React
    nodePackages.reveal-md # reveal.js on steroids! Get beautiful reveal.js presentations from your Markdown files.
    nodePackages.serverless # Serverless Framework - Build web, mobile and IoT applications with serverless architectures using AWS Lambda, Azure Functions, Google CloudFunctions & more
    nodePackages.svelte-check # Svelte Code Checker Terminal Interface
    nodePackages.svelte-language-server # A language server for Svelte
    nodePackages.tailwindcss # A utility-first CSS framework for rapidly building custom user interfaces.
    nodePackages.tern # A JavaScript code analyzer for deep, cross-editor language support
    nodePackages.vim-language-server # vim language server
    nodePackages.vls # Vue Language Server
    nodePackages.vue-cli # A simple CLI for scaffolding Vue.js projects.
    nodePackages.vue-language-server # vue-language-server
    nodePackages.webpack-cli # CLI for webpack & friends
    nodePackages.yaml-language-server # YAML language server
    nodePackages.yarn # Fast, reliable, and secure dependency management.
    nodePackages.yo # CLI tool for running Yeoman generators
  ];
}
