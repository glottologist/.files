{
  lib,
  python3Packages,
  fetchFromGitLab,
  meson,
  ninja,
  pkg-config,
  gettext,
  gobject-introspection,
  wrapGAppsHook4,
  desktop-file-utils,
  gtk4,
  libadwaita,
  libshumate,
  adwaita-icon-theme,
}:
python3Packages.buildPythonApplication {
  pname = "gtk-meshtastic-client";
  version = "1.5";
  format = "other";

  src = fetchFromGitLab {
    owner = "kop316";
    repo = "gtk-meshtastic-client";
    rev = "1.5";
    hash = "sha256-s91zyxCgUapOOrc3PfmoC3LzvKKBJK3vIDtNF+T9/0Q=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    gobject-introspection
    wrapGAppsHook4
    desktop-file-utils
  ];
  buildInputs = [
    gtk4
    libadwaita
    libshumate
    adwaita-icon-theme
  ];
  dependencies = with python3Packages; [
    meshtastic
    pygobject3
    pycairo
    dotmap
    pyqrcode
  ];

  postPatch = ''
    substituteInPlace test/test_utils.py \
      --replace-fail "../_build/test/test_support.py" "test/test_support.py"
  '';

  dontWrapGApps = true;
  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';
  doCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    meson test --print-errorlogs
    runHook postInstallCheck
  '';

  meta = {
    description = "GTK4 client for Meshtastic radios";
    homepage = "https://gitlab.com/kop316/gtk-meshtastic-client";
    license = lib.licenses.gpl3Plus;
    mainProgram = "gtk-meshtastic-client";
    platforms = lib.platforms.linux;
  };
}
