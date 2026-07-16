# CodexBar Linux CLI — prebuilt release binary from steipete/CodexBar.
# Used by codexbar-waybar to surface AI provider usage in Waybar.
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  curl,
  sqlite,
}:
stdenv.mkDerivation rec {
  pname = "codexbar";
  version = "0.43.0";

  src = fetchurl {
    url = "https://github.com/steipete/CodexBar/releases/download/v${version}/CodexBarCLI-v${version}-linux-x86_64.tar.gz";
    hash = "sha256-eTLLUtKc3CSZ4gYYRV2XDFCYkGFB+hjy2Un5gyfGjyE=";
  };

  nativeBuildInputs = [autoPatchelfHook];
  buildInputs = [
    curl
    sqlite
    stdenv.cc.cc.lib
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 CodexBarCLI $out/bin/codexbar
    runHook postInstall
  '';

  meta = {
    description = "Linux CLI for CodexBar AI usage limits";
    homepage = "https://github.com/steipete/CodexBar";
    license = lib.licenses.mit;
    platforms = ["x86_64-linux"];
    mainProgram = "codexbar";
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
}
