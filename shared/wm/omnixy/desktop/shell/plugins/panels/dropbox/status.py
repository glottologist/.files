import json
import os
import shutil
import socket
import subprocess
import sys
import heapq
from pathlib import Path



PLAN_QUOTAS = {
  "basic": 2_000_000_000,
  "plus": 2_000_000_000_000,
  "pro": 3_000_000_000_000,
  "professional": 3_000_000_000_000,
  "essentials": 3_000_000_000_000,
}


COMMAND_SOCKET = Path.home() / ".dropbox" / "command_socket"
SETTINGS_FILE = Path.home() / ".local" / "state" / "omnixy" / "dropbox-settings.json"
AUTOSTART_DESKTOP = Path.home() / ".config" / "autostart" / "dropbox.desktop"
# dropboxd keeps its cache beside the synced tree; it is never a sync folder.
HIDDEN_FOLDERS = {".dropbox.cache", ".dropbox"}


def daemon_command(name, **args):
  """Speak the dropboxd command socket protocol: a command line, tab-joined
  argument lines, "done", then "ok"/"notok" followed by result lines. This is
  the same wire format dropbox-cli uses; talking to it directly avoids a
  subprocess per query and reaches the getters the CLI never exposed."""
  try:
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.settimeout(5)
    sock.connect(str(COMMAND_SOCKET))
  except OSError:
    return None
  try:
    stream = sock.makefile("rw", 4096)
    stream.write(name + "\n")
    for key, value in args.items():
      values = [value] if isinstance(value, str) else list(value)
      stream.write("\t".join([key] + values) + "\n")
    stream.write("done\n")
    stream.flush()
    if stream.readline().rstrip("\n") != "ok":
      return None
    result = {}
    for _ in range(20):
      line = stream.readline().rstrip("\n")
      if line == "" or line == "done":
        break
      parts = line.split("\t")
      result[parts[0]] = parts[1:]
    return result
  except (OSError, ValueError):
    return None
  finally:
    sock.close()


def ignore_set():
  result = daemon_command("get_ignore_set")
  if not result:
    return []
  paths = [path for path in result.get("ignore_set", []) if path]
  return sorted(set(paths))


def bandwidth_limits():
  result = daemon_command("get_bandwidth_limits") or {}

  def first(key, fallback):
    values = result.get(key)
    return values[0] if values else fallback

  def number(key):
    try:
      return max(0, int(first(key, "0")))
    except ValueError:
      return 0

  return {
    "known": bool(result),
    "downloadMode": first("download_mode", "unlimited"),
    "uploadMode": first("upload_mode", "unlimited"),
    "downloadLimit": number("download_limit"),
    "uploadLimit": number("upload_limit"),
  }


def read_settings():
  try:
    with SETTINGS_FILE.open("r", encoding="utf-8") as handle:
      data = json.load(handle)
    return data if isinstance(data, dict) else {}
  except (OSError, json.JSONDecodeError):
    return {}


def write_settings(data):
  SETTINGS_FILE.parent.mkdir(parents=True, exist_ok=True)
  tmp = SETTINGS_FILE.with_suffix(".json.tmp")
  with tmp.open("w", encoding="utf-8") as handle:
    json.dump(data, handle)
  os.replace(tmp, SETTINGS_FILE)


def lan_sync_setting():
  value = read_settings().get("lanSync")
  return {"enabled": value if isinstance(value, bool) else True, "recorded": isinstance(value, bool)}


def autostart_state():
  """A NixOS host starts dropboxd from a systemd user unit, which makes the
  CLI's ~/.config/autostart desktop file irrelevant; report which mechanism
  is in charge so the panel can show the systemd case read-only."""
  systemctl = shutil.which("systemctl")
  if systemctl:
    code, output = command_output([systemctl, "--user", "show", "-p", "LoadState", "--value", "dropbox.service"])
    if code == 0 and output.strip() == "loaded":
      return {"managed": "systemd", "enabled": True}
  return {"managed": "desktop", "enabled": AUTOSTART_DESKTOP.exists()}


def read_info():
  info_path = Path.home() / ".dropbox" / "info.json"
  if not info_path.exists():
    return {}
  try:
    with info_path.open("r", encoding="utf-8") as handle:
      return json.load(handle)
  except (OSError, json.JSONDecodeError):
    return {}


def dropbox_account(info):
  for key in ("personal", "business"):
    account = info.get(key)
    if isinstance(account, dict):
      return account
  return {}


def command_output(command):
  try:
    completed = subprocess.run(command, check=False, capture_output=True, text=True, timeout=4)
  except (OSError, subprocess.TimeoutExpired):
    return 1, ""
  return completed.returncode, (completed.stdout + completed.stderr).strip()


def scan_dropbox(path, limit):
  total = 0
  counter = 0
  recent = []
  try:
    for root, dirs, files in os.walk(path):
      dirs[:] = [name for name in dirs if not os.path.islink(os.path.join(root, name))]
      for name in files:
        file_path = os.path.join(root, name)
        if os.path.islink(file_path):
          continue
        try:
          stat = os.stat(file_path)
        except OSError:
          continue
        total += stat.st_size
        rel = os.path.relpath(file_path, path)
        folder = os.path.dirname(rel)
        row = {
          "name": name,
          "path": file_path,
          "folder": "/" if folder in ("", ".") else folder,
          "modifiedTs": int(stat.st_mtime),
          "sizeBytes": stat.st_size,
        }
        counter += 1
        entry = (row["modifiedTs"], counter, row)
        if len(recent) < limit:
          heapq.heappush(recent, entry)
        else:
          heapq.heappushpop(recent, entry)
  except OSError:
    return 0, []
  rows = [entry[2] for entry in sorted(recent, reverse=True)]
  return total, rows


def list_folders(directory, excluded):
  """Subfolders of `directory` as the panel's sync browser sees them: what is
  on disk (synced) merged with ignore-set entries whose parent is this
  directory (excluded, hence absent from disk)."""
  directory = os.path.normpath(directory)
  entries = {}
  try:
    for name in os.listdir(directory):
      if name in HIDDEN_FOLDERS or name.startswith("."):
        continue
      path = os.path.join(directory, name)
      if os.path.isdir(path) and not os.path.islink(path):
        entries[name] = {"name": name, "path": path, "excluded": False, "excludedInside": 0}
  except OSError:
    pass
  for path in excluded:
    parent, name = os.path.split(os.path.normpath(path))
    if parent == directory and name:
      entries[name] = {"name": name, "path": os.path.join(directory, name), "excluded": True, "excludedInside": 0}
  for entry in entries.values():
    prefix = entry["path"] + os.sep
    entry["excludedInside"] = sum(1 for path in excluded if path.startswith(prefix))
  return [entries[name] for name in sorted(entries, key=str.casefold)]


def folders_command(directory, root_path):
  root = os.path.normpath(root_path) if root_path else ""
  directory = os.path.normpath(directory) if directory else root
  inside = root != "" and (directory == root or directory.startswith(root + os.sep))
  if not inside:
    print(json.dumps({"ok": False, "error": "Folder is outside Dropbox"}))
    return
  print(json.dumps({
    "ok": True,
    "path": directory,
    "rootPath": root,
    "folders": list_folders(directory, ignore_set()),
  }))


def lansync_command(value):
  dropbox_cli = shutil.which("dropbox-cli")
  if not dropbox_cli:
    print(json.dumps({"ok": False, "error": "dropbox-cli is not installed"}))
    return
  enabled = str(value).lower().startswith("y")
  code, output = command_output([dropbox_cli, "lansync", "y" if enabled else "n"])
  if code != 0 or "isn't" in output or "Couldn't" in output:
    print(json.dumps({"ok": False, "error": output or "dropbox-cli lansync failed"}))
    return
  settings = read_settings()
  settings["lanSync"] = enabled
  write_settings(settings)
  print(json.dumps({"ok": True, "lanSync": enabled}))


def main():
  args = sys.argv[1:]
  info = read_info()
  account = dropbox_account(info)
  account_path = account.get("path") if isinstance(account.get("path"), str) else ""
  root_path = account.get("root_path") if isinstance(account.get("root_path"), str) else account_path

  if args and args[0] == "folders":
    folders_command(args[1] if len(args) > 1 else root_path, root_path)
    return
  if args and args[0] == "lansync":
    lansync_command(args[1] if len(args) > 1 else "y")
    return

  limit = 25
  if args:
    try:
      limit = max(1, min(100, int(args[0])))
    except ValueError:
      limit = 25

  dropbox_cli = shutil.which("dropbox-cli")
  plan = account.get("subscription_type") if isinstance(account.get("subscription_type"), str) else ""
  quota = PLAN_QUOTAS.get(plan.lower(), 0)
  authenticated = account_path != "" and Path(account_path).exists()

  running = False
  status_text = "Not installed"
  if dropbox_cli:
    status_exit, status_output = command_output([dropbox_cli, "status"])
    status_text = status_output if status_exit == 0 and status_output else "Stopped"
    lowered = status_text.lower()
    stopped = "not running" in lowered or "isn't running" in lowered or lowered == "stopped"
    running = status_exit == 0 and status_output != "" and not stopped

  used, files = scan_dropbox(account_path, limit) if authenticated else (0, [])
  usage_percent = (used / quota * 100) if quota > 0 else 0
  lan_sync = lan_sync_setting()

  print(json.dumps({
    "ok": True,
    "installed": dropbox_cli is not None,
    "running": running,
    "authenticated": authenticated,
    "statusText": status_text,
    "accountPath": account_path,
    "plan": plan,
    "usedBytes": used,
    "quotaBytes": quota,
    "usagePercent": usage_percent,
    "quotaKnown": quota > 0,
    "files": files,
    "rootPath": root_path,
    "excluded": ignore_set() if running else [],
    "bandwidth": bandwidth_limits(),
    "lanSync": lan_sync["enabled"],
    "lanSyncRecorded": lan_sync["recorded"],
    "autostart": autostart_state(),
  }))


if __name__ == "__main__":
  main()
