# Worker toolchain for Ennio on Bebop to dispatch agent sessions here.
#
# The control plane launches `ennio-node` over SSH: it generates a token,
# writes it to the daemon's stdin (`--auth-token-stdin`), and passes the
# worker's repository and workspace roots. A persistent systemd unit would
# occupy port 9100 with a different token, so the bootstrap would see the
# port in use and skip launch — then fail auth against the unit.
#
# Agent CLIs are probed from the daemon's PATH, which for an SSH-launched
# process is the system profile, not jason's login profile. grok is on that
# profile so spawn works before jason-cloud is applied.
#
# XAI_API_KEY is in the environment for the same reason jason-cloud exports
# it as a session variable: unattended agent auth, with the key landing in
# the store.
{
  pkgs,
  username,
  ennio,
  ...
}:
let
  workspaceRoot = "/home/${username}/ennio-workspaces";
  # crane's buildPackage runs cargo test in a sandbox with no git or tmux,
  # which the node tests require. Those tests already run on the host.
  package = ennio.packages.${pkgs.stdenv.hostPlatform.system}.ennio-node.overrideAttrs (_: {
    doCheck = false;
  });
  grok = pkgs.callPackage ../../shared/ai/grok-build.nix { };
  grokApiKey = pkgs.lib.removeSuffix "\n" (builtins.readFile ../../secrets/grok-api-key.txt);
in
{
  environment.systemPackages = [
    package
    grok
  ];

  environment.variables = {
    XAI_API_KEY = grokApiKey;
    GROK_API_KEY = grokApiKey;
  };

  systemd.tmpfiles.rules = [
    "d ${workspaceRoot} 0750 ${username} users -"
  ];
}
