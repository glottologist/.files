{
  config,
  lib,
  pkgs,
  ...
}: {
  # Trading-stack mesh (Node 2 — bebop = 10.100.0.2).
  # Source: rendered by ansible at ~/trading-stack/wg0.conf.
  # Private key lives outside the nix store at /etc/wireguard/wg0-private.key
  # (root:root, mode 0600). Create it manually before the first rebuild.
  networking.firewall.trustedInterfaces = [ "wg0" ];

  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.100.0.2/24" ];
    privateKeyFile = "/etc/wireguard/wg0-private.key";
    peers = [
      {
        # node1 — calypso
        publicKey = "zY2/ixFemjue76847OeeQwDzHhrAMF4CBRGJ8rtol0M=";
        allowedIPs = [ "10.100.0.1/32" ];
        endpoint = "51.89.205.122:51820";
        persistentKeepalive = 25;
      }
      {
        # node3 — circe
        publicKey = "TbBys9cAwXqNMKdTGWmVt1J8zZX/sow1mdQFEMeL2Fk=";
        allowedIPs = [ "10.100.0.3/32" ];
        endpoint = "51.89.205.123:51820";
        persistentKeepalive = 25;
      }
    ];
  };
}
