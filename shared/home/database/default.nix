{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    dbeaver       # Universal SQL Client for developers, DBA and analysts. Supports MySQL, PostgreSQL, MariaDB, SQLite, and more
  ];
}
