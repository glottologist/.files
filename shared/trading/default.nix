{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    tradingview
  ];
}
