# jason owns the desktop, the Ennio workspaces and the Syncthing folder.
# No password is declared: RDP needs one, and it is set interactively with
# passwd after installation so that no hash reaches Git or the Nix store.
{ pkgs, ... }:
let
  authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILN1szb/fBxMMUgpClXaFd4zR71B5/02Ij9jV4wxKW+o jason@glottologist.co.uk"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGltaXKSi2xO4uke2DcPj2j57M/VnsLskKX//JdJrm3C jason@ridgway-taylor.co.uk"
  ];
in
{
  users.users.jason = {
    isNormalUser = true;
    description = "jason";
    shell = pkgs.fish;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "input" ];
    openssh.authorizedKeys.keys = authorizedKeys;
  };

  users.users.root.openssh.authorizedKeys.keys = authorizedKeys;

  programs.fish.enable = true;
}
