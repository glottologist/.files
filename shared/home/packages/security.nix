{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
     keybase-gui                  # The Keybase official GUI
     _1password                   # 1Password command-line tool
     _1password-gui               # Multi-platform password manager
     lastpass-cli                 # Stores, retrieves, generates, and synchronizes passwords securely
     pam_u2f                      # A PAM module for allowing authentication with a U2F device
     paperkey                     # Store OpenPGP or GnuPG on paper
     pass                         # Stores, retrieves, generates, and synchronizes passwords securely
     pinentry-curses              # GnuPG’s interface to passphrase input
     vault                        # Hashicorp vault
     veracrypt                    # Free Open-Source filesystem on-the-fly encryption
     yubico-pam                   # Yubico PAM module
     yubico-piv-tool              # Used for interacting with the Privilege and Identification Card (PIV) application on a YubiKey
     yubikey-agent                # A seamless ssh-agent for YubiKeys
     yubikey-manager              # Command line tool for configuring any YubiKey over all USB transports
     yubikey-manager-qt           # Cross-platform application for configuring any YubiKey over all USB interfaces
     yubikey-personalization      # A library and command line tool to personalize YubiKeys
     yubioath-desktop             # Yubico Authenticator
  ];
}
