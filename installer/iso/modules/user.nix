{pkgs, config, lib, ...}:
{
  users.users.jason= {
    name = "jason";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    uid = 1000;
    initialPassword = "jason";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILN1szb/fBxMMUgpClXaFd4zR71B5/02Ij9jV4wxKW+o jason@glottologist.co.uk"
    ];
  };

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  system.activationScripts = {
    bashSetup.text = ''
      mkdir -p /home/jason
      cat << EOF > /home/jason/.bashrc
      neofetch
      echo "NixOS installer."
      echo "Use network manager to connect to wifi:"
      echo 'nmcli dev wifi con "NetworkSID" password "YourPassword"'
      echo "nixos-help - Will open the nixos manual"
      echo ""
      echo "Extra setup commands:"
      echo "setupdisk {vm|crypt} {device} - Sets up a disk ready for nixos install (only use if you want my layout)."
      echo ""
      EOF
      chown 1000:1000 /home/jason -R
    '';
  };
}
