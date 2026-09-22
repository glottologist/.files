# Keybase and KBFS, bebop only. The shared communication module dropped them
# for every host; this home config is bebop's alone.
{pkgs, ...}: {
  # services.keybase adds the keybase CLI and services.kbfs the kbfsfuse
  # binary, so only the GUI needs listing here.
  home.packages = [pkgs.keybase-gui];

  services = {
    # Keybase is a key directory that maps social media identities to
    # encryption keys in a publicly auditable manner.
    keybase.enable = true;
    # Mounts the Keybase filesystem at ~/keybase.
    kbfs.enable = true;
  };
}
