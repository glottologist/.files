{
  config,
  pkgs,
  ...
}: let
  # rpi-imager 2.x writes to the raw block device, so it must run as root.
  # Its own "Install Authorization" button only works for the AppImage build
  # and writes into /etc/polkit-1, which NixOS manages. This build ships the
  # polkit action itself and points the menu entry at pkexec instead.
  #
  # pkexec matches exec.path against the realpath of the program, so both
  # sides name the store path of the binary rather than a profile symlink.
  # Under pkexec the imager rebuilds XDG_RUNTIME_DIR and WAYLAND_DISPLAY
  # from PKEXEC_UID, so the window still reaches the user's session.
  rpiImager = "${pkgs.rpi-imager}/bin/rpi-imager";
  rpi-imager-elevated = pkgs.symlinkJoin {
    name = "rpi-imager-elevated-${pkgs.rpi-imager.version}";
    paths = [pkgs.rpi-imager];
    postBuild = ''
      desktop=share/applications/com.raspberrypi.rpi-imager.desktop
      rm $out/$desktop
      substitute ${pkgs.rpi-imager}/$desktop $out/$desktop \
        --replace-fail "Exec=rpi-imager %u" "Exec=/run/wrappers/bin/pkexec ${rpiImager} %u"

      mkdir -p $out/share/polkit-1/actions
      cat > $out/share/polkit-1/actions/com.raspberrypi.rpi-imager.pkexec.policy <<EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE policyconfig PUBLIC
       "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN"
       "http://www.freedesktop.org/standards/PolicyKit/1.0/policyconfig.dtd">
      <policyconfig>
        <action id="com.raspberrypi.rpi-imager.pkexec">
          <description>Run Raspberry Pi Imager</description>
          <message>Raspberry Pi Imager needs administrator rights to write to storage devices</message>
          <defaults>
            <allow_any>auth_admin</allow_any>
            <allow_inactive>auth_admin</allow_inactive>
            <allow_active>auth_admin_keep</allow_active>
          </defaults>
          <annotate key="org.freedesktop.policykit.exec.path">${rpiImager}</annotate>
          <annotate key="org.freedesktop.policykit.exec.allow_gui">true</annotate>
        </action>
      </policyconfig>
      EOF
    '';
  };
in {
  environment.systemPackages = with pkgs; [
   exfatprogs # Exfat utils that work wih gparted
    fuse3 # Fuse filesystems
    gparted # Graphical disk partitioning tool
    lethe # Tool to wipe drives in a secure way
    ntfs3g # FUSE-based NTFS driver with full write support
    parted # Create, destroy, resize, check, and copy partitions
    rpi-imager-elevated # Raspberry Pi Imaging Utility, launched through pkexec
    tree # Command to produce a depth indented directory listing
    ventoy # Create bootable USB drives from ISO files
    woeusb # Create bootable USB diskc from Windows ISO images
    woeusb-ng # Create bootable USB diskc from Windows ISO images
  ];
}
