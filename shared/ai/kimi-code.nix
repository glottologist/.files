# Kimi Code CLI — Moonshot AI's coding agent
# (https://platform.kimi.ai/docs/guide/kimi-code-cli).
#
# Distributed as prebuilt single binaries via
# `curl https://code.kimi.com/kimi-code/install.sh | bash` (also on npm as
# @moonshot-ai/kimi-code); not in nixpkgs, so we pin the upstream artifact by
# hash. The linux-x64 build is dynamically linked against glibc and libstdc++,
# hence autoPatchelfHook.
#
# To update: read the latest version from
#   https://code.kimi.com/kimi-code/latest
# bump `version`, then take the linux-x64 sha256 from the upstream manifest
#   https://code.kimi.com/kimi-code/binaries/<version>/manifest.json
# and convert it: `nix hash convert --hash-algo sha256 <hex>`
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "kimi-code";
  version = "0.27.0";

  src = fetchurl {
    url = "https://code.kimi.com/kimi-code/binaries/${finalAttrs.version}/kimi-code-linux-x64";
    hash = "sha256-7surRbwbmStkjEY4eglyw0D6x9iyVJYW8erOyQ5ZWjE=";
  };

  nativeBuildInputs = [autoPatchelfHook];
  buildInputs = [stdenv.cc.cc.lib];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  # Upstream ships the binary unstripped with embedded payload data; leave it
  # exactly as released apart from the ELF patching.
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/kimi"
    runHook postInstall
  '';

  # Verify the patched binary actually executes, mirroring the check the
  # upstream installer performs after download.
  doInstallCheck = true;
  installCheckPhase = ''
    "$out/bin/kimi" --version
  '';

  meta = {
    description = "Moonshot AI Kimi Code CLI coding agent, prebuilt binary";
    homepage = "https://platform.kimi.ai/docs/guide/kimi-code-cli";
    license = lib.licenses.mit;
    mainProgram = "kimi";
    platforms = ["x86_64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
})
