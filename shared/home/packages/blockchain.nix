
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    ergo             # Open protocol that implements modern scientific ideas in the blockchain area
    go-ethereum      # Official golang implementation of the Ethereum protocol
    ipfs             # A global, versioned, peer-to-peer filesystem
    monero           # Private, secure, untraceable currency
    monero-gui       # Private, secure, untraceable currency
    polkadot         # Polkadot Node Implementation
    #urbit            # An operating function
    zcash            # Peer-to-peer, anonymous electronic cash system
  ];
}
