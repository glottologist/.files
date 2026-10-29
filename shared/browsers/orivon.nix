# Orivon — Electron browser (https://github.com/OrivonBrowser/orivon-mvp).
# Prebuilt x86_64 AppImage; not in nixpkgs. Releases so far are pre-releases.
#
# To update: bump `version` and refresh `hash` from the GitHub release asset
#   Orivon-<version>-x86_64.AppImage (digest published on the release).
{
  lib,
  appimageTools,
  fetchurl,
  makeDesktopItem,
}:
let
  pname = "orivon";
  version = "0.0.12";

  src = fetchurl {
    url = "https://github.com/OrivonBrowser/orivon-mvp/releases/download/v${version}/Orivon-${version}-x86_64.AppImage";
    hash = "sha256-K0McPDvNdHK8y5pIlGy2DnD2K2Tebdf9iexIhFc+nAo=";
  };

  contents = appimageTools.extract { inherit pname version src; };

  desktopItem = makeDesktopItem {
    name = "orivon";
    desktopName = "Orivon Browser";
    exec = "orivon %U";
    icon = "orivon";
    comment = "A browser that runs applications Chrome cannot";
    categories = [
      "Network"
      "WebBrowser"
    ];
    startupWMClass = "orivon";
    mimeTypes = [
      "text/html"
      "application/xhtml+xml"
      "image/svg+xml"
      "application/pdf"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/orivon"
    ];
    actions = {
      new-window = {
        name = "New Window";
        exec = "orivon --new-window";
      };
      new-private-window = {
        name = "New Private Window";
        exec = "orivon --new-private-window";
      };
    };
  };
in
appimageTools.wrapAppImage {
  inherit pname version;

  # Already extracted for the icon. wrapType2 would extract it again.
  src = contents;

  extraInstallCommands = ''
    install -Dm444 ${desktopItem}/share/applications/orivon.desktop \
      $out/share/applications/orivon.desktop
    if [[ -d ${contents}/usr/share/icons/hicolor ]]; then
      mkdir -p $out/share/icons
      cp -r ${contents}/usr/share/icons/hicolor $out/share/icons/hicolor
    elif [[ -f ${contents}/orivon.png ]]; then
      install -Dm444 ${contents}/orivon.png \
        $out/share/icons/hicolor/512x512/apps/orivon.png
    else
      echo "orivon AppImage has no icon" >&2
      exit 1
    fi
  '';

  meta = {
    description = "Browser that runs applications Chrome cannot, under user-granted per-app capabilities";
    homepage = "https://github.com/OrivonBrowser/orivon-mvp";
    license = lib.licenses.agpl3Only;
    mainProgram = "orivon";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
