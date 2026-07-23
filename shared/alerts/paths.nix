# Shared between the bridge daemon and the waybar module, which must agree on
# where the unread counter lives and which signal prompts waybar to reread it.
# Signal 8 already belongs to the codexbar module, hence 9 here.
{
  stateFileShell = "\${XDG_RUNTIME_DIR:-/tmp}/pushover/unread";
  stateFileSystemd = "%t/pushover/unread";
  waybarSignal = 9;
}
