# Waybar custom module + GTK4 popover wrapping the CodexBar Linux CLI.
# Upstream: https://github.com/Marouan-chak/codexbar-waybar
{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  python3,
  jq,
  gtk4,
  gtk4-layer-shell,
  libadwaita,
  gobject-introspection,
  glib,
  openssl,
  lsof,
  coreutils,
  gnugrep,
  gawk,
  gnused,
  procps,
  codexbar,
}:
let
  pythonEnv = python3.withPackages (ps: [ps.pygobject3]);
  giTypelibPath = lib.makeSearchPathOutput "lib" "girepository-1.0" [
    gtk4
    gtk4-layer-shell
    libadwaita
    gobject-introspection
    glib
  ];
  binPath = lib.makeBinPath [
    jq
    openssl
    lsof
    coreutils
    gnugrep
    gawk
    gnused
    procps
    codexbar
  ];
  layerShellLib = "${gtk4-layer-shell}/lib/libgtk4-layer-shell.so";
  commonWrapArgs = [
    "--prefix"
    "PATH"
    ":"
    binPath
    "--set"
    "CODEXBAR_BIN"
    "${codexbar}/bin/codexbar"
  ];
in
  stdenv.mkDerivation rec {
    pname = "codexbar-waybar";
    version = "0.4.0";

    src = fetchFromGitHub {
      owner = "Marouan-chak";
      repo = "codexbar-waybar";
      rev = "v${version}";
      hash = "sha256-vfY/FYSJnNI1GO+EKWVad2FcJZ1mooYcamsXTqYaxJM=";
    };

    nativeBuildInputs = [makeWrapper];

    buildPhase = ''
      runHook preBuild
      $CC -shared -fPIC -o cert_redirect.so cert_redirect.c -ldl
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      libexec=$out/libexec/codexbar-waybar
      mkdir -p $libexec $out/share/codexbar-waybar/icons $out/share/waybar $out/bin

      install -Dm755 codexbar.sh $libexec/.codexbar.sh-wrapped
      install -Dm755 codexbar-popup.py $libexec/codexbar-popup.py
      install -Dm755 cert_redirect.so $libexec/cert_redirect.so
      install -Dm644 codexbar.css $out/share/waybar/codexbar.css

      if [ -d assets/providers ]; then
        install -Dm644 assets/providers/ProviderIcon-*.svg $out/share/codexbar-waybar/icons/ || true
        [ -f assets/providers/NOTICE ] && \
          install -Dm644 assets/providers/NOTICE $out/share/codexbar-waybar/icons/NOTICE
      fi

      # Shell module — WRAPPER path used by the popup is this same directory.
      makeWrapper $libexec/.codexbar.sh-wrapped $libexec/codexbar.sh \
        ${lib.escapeShellArgs commonWrapArgs}
      ln -s $libexec/codexbar.sh $out/bin/codexbar-waybar

      # GTK4 popover — keep the .py next to codexbar.sh so SCRIPT_DIR resolves.
      makeWrapper ${pythonEnv}/bin/python $out/bin/codexbar-popup \
        --add-flags $libexec/codexbar-popup.py \
        ${lib.escapeShellArgs commonWrapArgs} \
        --set CODEXBAR_LAYER_SHELL_LIB ${layerShellLib} \
        --prefix GI_TYPELIB_PATH : ${giTypelibPath} \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
          gtk4-layer-shell
          gtk4
          libadwaita
          glib
        ]}

      runHook postInstall
    '';

    meta = {
      description = "Waybar custom module + GTK4 popover for the CodexBar Linux CLI";
      homepage = "https://github.com/Marouan-chak/codexbar-waybar";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
      mainProgram = "codexbar-waybar";
    };
  }
