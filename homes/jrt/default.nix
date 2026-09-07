# The jrt profile for Chimera, the GPD Pocket 3.
#
# Chimera exists to do four things — writing, AI and agents, reaching other
# machines over SSH and the tailnet, and running NymVPN — and this profile is
# scoped to exactly those. It is emphatically not homes/jason, which carries a
# workstation's breadth: blockchain toolchains, trading terminals, comics,
# media, pentesting, virtualisation, databases and forty language modules. None
# of that serves an eight-inch machine chosen for being carried.
#
# The reasoning follows homes/jason-cloud: import a shared module where it is
# already scoped to one of the four capabilities, and take the narrower path
# where the module would drag a workstation along behind it.
#
# The API keys are exported as they are in the other profiles. Their content
# reaches the world-readable Nix store, which is the standing trade-off in this
# repository for unattended agent authentication; on a portable machine the
# disk encryption in hosts/chimera/disko.nix is what carries the weight.
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

  systemd.user.targets = {
    tray = {
      Unit = {
        Description = "Home Manager System Tray";
        Requires = ["graphical-session-pre.target"];
      };
    };
    hyprland-session.Unit.Wants = [
      "xdg-desktop-autostart.target"
    ];
  };

  qt.platformTheme = "gtk2";

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

    # Writing. shared/documentation covers the technical artefacts — mdBook,
    # the LaTeX editors, the PDF tooling — while shared/writing covers the
    # prose: the editors, the linters, the British dictionaries and the readers.
    ../../shared/writing/default.nix
    ../../shared/documentation/default.nix
    ../../shared/languages/latex
    ../../shared/languages/markdown
    ../../shared/languages/typst

    # AI and agents. This module is already scoped precisely to its name and
    # brings every agent CLI, its configuration and its shared skills.
    ../../shared/ai/default.nix

    # Reaching other machines. shared/network carries the remote-desktop and
    # diagnostic tools and, more importantly, imports the SSH host
    # configuration from secrets/ssh.nix. Tailscale itself is a system concern
    # and arrives through hosts/common/tailscale.nix.
    ../../shared/network/default.nix
    ../../shared/security/default.nix

    # The session and the shell. Only the classic Hyprland profile is taken:
    # shared/wm/default.nix would add Caelestia and Omnixy, both tuned to
    # Bebop's monitor geometry and needing a second round of rotation work for
    # no gain on this panel. Plasma comes from the system layer.
    ../../shared/wm/classic/default.nix
    ../../shared/wm/stylix.nix
    ../../shared/desktop/default.nix
    ../../shared/terminal/default.nix
    ../../shared/fonts/default.nix

    # A browser is not decoration here: Claude Code authenticates through Max
    # OAuth and needs one to complete a login.
    ../../shared/browsers/default.nix

    # Git identity and configuration, taken directly rather than through
    # shared/development, which also carries VS Code, Windsurf, Jupyter and a
    # JDK — desktop development software this machine is not for.
    ../../shared/development/git
    ../../shared/languages/nix
    ../../shared/languages/shell
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
      BROWSER = "zen-browser";
      TERMINAL = "ghostty";
      # ANTHROPIC_API_KEY intentionally not exported — Claude Code uses Max OAuth.
      OPENAI_API_KEY = openai_api_key;
      GROK_API_KEY = grok_api_key;
      XAI_API_KEY = grok_api_key;
    };
    pointerCursor = {
      gtk.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      # Larger than Bebop's 22: at roughly 283 DPI a default cursor is a speck.
      size = 32;
    };
    stateVersion = "26.05";
  };

  # Make home manager news silent
  news.display = "silent";
}
