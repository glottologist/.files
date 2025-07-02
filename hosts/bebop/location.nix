{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };

  environment.systemPackages = with pkgs; [
    icu # Unicode and globalization support library
  ];
    environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";           # Enable Wayland for Chromium/Electron apps
    MOZ_ENABLE_WAYLAND = "1";       # Enable Wayland for Firefox
  };
}
