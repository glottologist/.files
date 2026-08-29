# Aether — visual theming app from omacom-io (https://github.com/omacom-io/aether).
# Prebuilt Wails/WebKitGTK linux-amd64 binary; not in nixpkgs.
#
# To update: bump `version` and refresh `hash` from the GitHub release asset
#   aether-linux-amd64 (digest published on the release).
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  gtk3,
  glib,
  webkitgtk_4_1,
  gtk-layer-shell,
  pango,
  cairo,
  gdk-pixbuf,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "aether";
  version = "4.29.6";

  src = fetchurl {
    url = "https://github.com/omacom-io/aether/releases/download/v${finalAttrs.version}/aether-linux-amd64";
    hash = "sha256-R7WvpBRLOjzXdVUklW/+awdO1fL5Da3aI+Qk7+r4h5A=";
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
  ];
  buildInputs = [
    gtk3
    glib
    webkitgtk_4_1
    gtk-layer-shell
    pango
    cairo
    gdk-pixbuf
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" $out/bin/aether
    runHook postInstall
  '';

  meta = {
    description = "Visual theming application for Omarchy and other Linux desktops";
    homepage = "https://github.com/omacom-io/aether";
    license = lib.licenses.mit;
    platforms = ["x86_64-linux"];
    mainProgram = "aether";
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
})
