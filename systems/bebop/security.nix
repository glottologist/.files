{ lib, ... }:
{
  security.rtkit.enable = true;
 # security.pam.services.sddm.enableGnomeKeyring = true;
  security.pam.services.lightdm.enableGnomeKeyring = true;
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.swaylock = { };
  ssh.startAgent = true;

}
