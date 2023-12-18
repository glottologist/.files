{
  config,
  pkgs,
  ...
}: {
  time.timeZone = "Asia/Bangkok";
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };

  environment.systemPackages = with pkgs; [
    icu # Unicode and globalization support library
  ];
}
