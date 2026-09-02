# The reduced jason profile for the Hetzner agent hosts, Reliant and Defiant.
#
# This is homes/jason with the window-manager, desktop, media, comics, trading,
# pentesting, pictures, learning, productivity, cloud, documentation, database,
# communication, blockchain, disk, virtualization and browser modules removed.
# What remains is what an agent host actually uses: the agent CLIs and their
# configuration, a development toolchain, a shell, and the fonts a Plasma
# session needs to be legible.
#
# Plasma, SDDM and the browsers come from the system layer on these hosts, not
# from here. Stylix is absent because only shared/wm consumes it.
#
# The API keys are exported deliberately. Their content reaches the Nix store,
# which is world-readable, and these are public-facing machines; the user was
# shown that consequence and chose unattended agent authentication over the
# reduction in exposure. Dropping the three sessionVariables below and the
# .ouroboros/.env entry in shared/ai is the whole of the reversal, at the cost
# of an interactive login per host.
{
  pkgs,
  lib,
  ...
}: let
  inherit (import ./variables.nix) username;

  homeDirectory = "/home/${username}";
  configHome = "${homeDirectory}/.config";

  openai_api_key = pkgs.lib.removeSuffix "\n" (builtins.readFile ../../secrets/openai-api-key.txt);
  grok_api_key = pkgs.lib.removeSuffix "\n" (builtins.readFile ../../secrets/grok-api-key.txt);

  defaultPkgs = with pkgs; [
    any-nix-shell # fish support for nix shell
  ];
in {
  programs.home-manager = {
    enable = true;
  };

  home.enableNixpkgsReleaseCheck = false;

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-12.2.3"
      "electron-13.6.9"
      "libgit2-0.27.10"
    ];
  };

  imports = [
    ../../secrets/accounts.nix
    ../../shared/ai/default.nix
    # Git identity and configuration, taken directly rather than through
    # shared/development, which also carries VS Code, Windsurf, Jupyter,
    # netlify-cli and a JDK. Those, along with shared/security's 1Password and
    # Vault and shared/network's TeamViewer, are desktop software for Bebop and
    # cost several gigabytes each on a machine whose whole disk is 38 GiB. The
    # command-line tools an agent genuinely needs live in the host's
    # environment.systemPackages instead.
    ../../shared/development/git
    # Not shared/languages/default.nix: it imports some forty language modules,
    # and the Haskell and LaTeX ones alone took the closure past 62 GB — more
    # than Defiant's entire disk. The subset below is what an agent host
    # actually compiles in.
    ../../shared/languages/nix
    ../../shared/languages/python
    ../../shared/languages/javascript
    ../../shared/languages/typescript
    ../../shared/languages/rust
    ../../shared/languages/shell
    ../../shared/languages/markdown
    ../../shared/terminal/default.nix
  ];


  xdg = {
    inherit configHome;
    enable = true;
  };

  home = {
    inherit username homeDirectory;

    packages = defaultPkgs;

    sessionVariables = {
      EDITOR = "vim";
      # Firefox comes from the system layer; shared/browsers is not imported.
      BROWSER = "firefox";
      TERMINAL = "kitty";
      # ANTHROPIC_API_KEY intentionally not exported — Claude Code uses Max OAuth.
      OPENAI_API_KEY = openai_api_key;
      GROK_API_KEY = grok_api_key;
      XAI_API_KEY = grok_api_key;
    };
    stateVersion = "26.05";
  };

  # Make home manager news silent
  news.display = "silent";
}
