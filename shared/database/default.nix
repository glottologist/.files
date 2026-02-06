{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    dbeaver-bin # Universal SQL Client for developers, DBA and analysts. Supports MySQL, PostgreSQL, MariaDB, SQLite, and more
    sqlite
  ];
}
