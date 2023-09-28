{ lib, ... }:
{
  security.rtkit.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

}
