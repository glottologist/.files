{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    _1password-cli # 1Password command-line tool
    _1password-gui # Multi-platform password manager
    croc # Easily and securely send things from one computer to another
    lastpass-cli # Stores, retrieves, generates, and synchronizes passwords securely
    pam_u2f # A PAM module for allowing authentication with a U2F device
    paperkey # Store OpenPGP or GnuPG on paper
    pass # Stores, retrieves, generates, and synchronizes passwords securely
    proton-pass # Desktop application for Proton Pass
    protonmail-desktop # Desktop application for Proton Mail
    protonvpn-gui # GUI client for ProtonVPN
    protonvpn-cli # CLI client for ProtonVPN
    pinentry-curses # GnuPG’s interface to passphrase input
    vault # Hashicorp vault
    yubico-pam # Yubico PAM module
    yubico-piv-tool # Used for interacting with the Privilege and Identification Card (PIV) application on a YubiKey
    yubikey-agent # A seamless ssh-agent for YubiKeys
    #yubikey-manager              # Command line tool for configuring any YubiKey over all USB transports
    yubikey-manager-qt # Cross-platform application for configuring any YubiKey over all USB interfaces
    veracrypt #Free Open-Source filesystem on-the-fly encryption
    yubikey-personalization # A library and command line tool to personalize YubiKeys
    yubikey-personalization-gui # A GUI to personalize YubiKeys
  ];
}
