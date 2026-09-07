# NymVPN core — the daemon and CLI from upstream's prebuilt Linux release.
#
# nixpkgs carries `nym`, which is the mixnet node and client tooling and gives a
# per-application SOCKS5 proxy; it does not carry the VPN client, which is what
# provides a device-wide tunnel. Upstream publishes a statically laid out
# release tarball for x86_64 Linux, so we patch that rather than build the Rust
# workspace, which vendors a very large dependency tree.
#
# The tarball holds five binaries. nym-vpnd is the privileged daemon that
# creates the tunnel and rewrites routing; nym-vpnc drives it over its local
# socket. The remaining three — nym-socks5-proxy, nym-exclude and
# nym-diagnostic — are the SOCKS5 front end, the split-tunnel helper and the
# support-bundle collector.
#
# Bumping the version means bumping `hash` alongside it; upstream publishes a
# .sha256sum asset next to each tarball.
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dbus,
  libmnl,
  libnftnl,
}:
stdenv.mkDerivation rec {
  pname = "nym-vpn-core";
  version = "2026.12.3";

  src = fetchurl {
    url = "https://github.com/nymtech/nym-vpn-client/releases/download/nym-vpn-v${version}/nym-vpn-core-v${version}_linux_x86_64.tar.gz";
    hash = "sha256-PbWzSkYbqmg8Gdww17dJ8X0xsY283w5ItyEEiiX2yv4=";
  };

  nativeBuildInputs = [autoPatchelfHook];

  # nym-vpnd speaks to nftables over netlink directly, hence libmnl and
  # libnftnl; the daemon and nym-diagnostic both talk to D-Bus.
  buildInputs = [
    dbus
    libmnl
    libnftnl
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall
    for binary in nym-vpnd nym-vpnc nym-socks5-proxy nym-exclude nym-diagnostic; do
      install -Dm755 "$binary" "$out/bin/$binary"
    done
    runHook postInstall
  '';

  meta = {
    description = "NymVPN daemon and command-line client";
    homepage = "https://github.com/nymtech/nym-vpn-client";
    license = lib.licenses.gpl3Only;
    platforms = ["x86_64-linux"];
    mainProgram = "nym-vpnc";
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
}
