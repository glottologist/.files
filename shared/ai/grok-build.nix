# Grok CLI ("Grok Build") — xAI's coding agent (https://docs.x.ai/build/overview).
#
# Distributed only as a closed-source, prebuilt single binary via
# `curl https://x.ai/cli/install.sh | bash`; there is no published source and it
# is not in nixpkgs, so we pin the upstream artifact by hash.
#
# The linux-x86_64 build is a static-pie ELF — no ELF interpreter and no shared
# library dependencies (verified: `patchelf --print-needed` is empty, there is no
# `.interp` section). It therefore needs neither autoPatchelfHook nor nix-ld and
# runs from the store unmodified; installing it is a plain copy onto PATH. The
# upstream installer also exposes the same binary under the name `agent`, so we
# mirror that with a symlink.
#
# To update: read the current stable version from
#   https://storage.googleapis.com/grok-build-public-artifacts/cli/stable
# bump `version`, then refresh `hash`, e.g.
#   nix store prefetch-file --hash-type sha256 \
#     https://storage.googleapis.com/grok-build-public-artifacts/cli/grok-<version>-linux-x86_64
{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "grok-build";
  version = "0.2.101";

  src = fetchurl {
    url = "https://storage.googleapis.com/grok-build-public-artifacts/cli/grok-${finalAttrs.version}-linux-x86_64";
    hash = "sha256-JVYpnN7Tf4HlTAJCDPp/Gi35/qtypEWGmg9VluFDszM=";
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  # Static-pie and already stripped: nothing for the default fixup to patch.
  dontStrip = true;
  dontPatchELF = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/grok"
    ln -s grok "$out/bin/agent"
    runHook postInstall
  '';

  # Verify the packaged binary actually runs, the same check the upstream
  # installer performs before it will replace an existing install.
  doInstallCheck = true;
  installCheckPhase = ''
    "$out/bin/grok" --version
  '';

  meta = {
    description = "xAI Grok coding agent CLI (Grok Build), prebuilt static binary";
    homepage = "https://docs.x.ai/build/overview";
    license = lib.licenses.unfree;
    mainProgram = "grok";
    platforms = ["x86_64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
})
