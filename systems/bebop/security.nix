{ lib, ... }:
{
  security.rtkit.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
  security.pam.services.lightdm.enableGnomeKeyring = true;
  security.pam.services.enableGnomeKeyring = true;
  security.pam.services.swaylock = {
   text = "auth include login";
  };
  ssh.startAgent = true;

}
