---
name: omnixy
description: >
  REQUIRED for end-user customization of Linux desktop, window manager, or system config.
  Use when editing ~/.config/hypr/, ~/.config/omnixy/,
  ~/.config/alacritty/, ~/.config/foot/, ~/.config/kitty/, or ~/.config/ghostty/.
  Triggers: Hyprland, window rules, animations, keybindings, monitors, gaps, borders,
  blur, opacity, omnixy-shell, bar, terminal config, themes, background,
  night light, idle, lock screen, screenshots, reminders, layer rules, workspace
  settings, display config, and user-facing omnixy commands. Excludes Omnixy
  source development through `omnixy dev link` workflows.
---

# Omnixy Skill

Manage [Omnixy](https://omarchy.org/) Linux systems - a beautiful, modern, opinionated Arch Linux distribution with Hyprland.

This skill is for end-user customization on installed systems.
It is not for contributing to Omnixy source code.

## When This Skill MUST Be Used

**ALWAYS invoke this skill for end-user requests involving ANY of these:**

- Editing ANY file in `~/.config/hypr/` (window rules, animations, keybindings, monitors, etc.)
- Editing `~/.config/omnixy/shell.json` (status bar layout, widgets)
- Editing terminal configs (alacritty, foot, kitty, ghostty)
- Editing ANY file in `~/.config/omnixy/`
- Window behavior, animations, opacity, blur, gaps, borders
- Layer rules, workspace settings, display/monitor configuration
- Themes, backgrounds, fonts, appearance changes
- User-facing `omnixy` commands (`omnixy theme ...`, `omnixy refresh ...`, `omnixy restart ...`, etc.)
- Screenshots, screen recording, reminders, night light, idle behavior, lock screen

**If you're about to edit a config file in ~/.config/ on this system, STOP and use this skill first.**

**Do NOT use this skill for Omnixy development tasks** (editing the Omnixy source tree, creating migrations, or running `omnixy dev ...` workflows).

## Topic Guides

Deeper instructions for common areas live next to this file. Read the
matching guide before starting:

- [`hyprland.md`](hyprland.md) - keybindings, monitors, window rules, and other Hyprland config
- [`plugins.md`](plugins.md) - the Omnixy shell: bar layout, widgets, plugins, idle behavior
- [`theming.md`](theming.md) - themes, backgrounds, and fonts
- [`hooks.md`](hooks.md) - automation hooks that run on system events
- [`capture.md`](capture.md) - screenshots, screen recordings, OCR text capture, and file sharing
- [`contributing.md`](contributing.md) - reporting Omnixy bugs and submitting fixes upstream

## Critical Safety Rules

For privileged commands, follow the Privilege Escalation rules below: `sudo` when a terminal is available for the password prompt, `pkexec` when it is not. Do not wrap commands that already manage privilege elevation themselves.

**For end-user customization tasks, NEVER modify anything in `/usr/share/omnixy/`** - but READING is safe and encouraged.

This directory is owned by the omnixy package. Any local changes will be
overwritten on the next `omnixy update`.

```
/usr/share/omnixy/     # READ-ONLY - NEVER EDIT (reading is OK)
├── bin/                    # Command source (packaged binaries are on PATH)
├── config/                 # Default config templates
├── themes/                 # Stock themes
├── default/                # System defaults
├── shell/                  # Omnixy shell source and defaults
├── migrations/             # Update migrations
└── install/                # Installation scripts
```

**Reading `/usr/share/omnixy/` is SAFE and useful** - do it freely to:
- Understand how omnixy commands work: `omnixy theme set --help` or `cat $(which omnixy-theme-set)`
- See default configs before customizing: `cat "$OMNIXY_PATH/config/omnixy/shell.json"`
- Check stock theme files to copy for customization
- Reference default hyprland settings: `cat /usr/share/omnixy/default/hypr/*`

**Always use these safe locations instead:**
- `~/.config/` - User configuration (safe to edit)
- `~/.config/omnixy/themes/<custom-name>/` - Custom themes
- `~/.config/omnixy/hooks/` - Custom automation hooks

If the request is to develop Omnixy itself, this skill is out of scope. Follow repository development instructions instead of this skill.

## Privilege Escalation

For an interactive script or command run in a visible terminal, use `sudo` for
privileged work. Omnixy may grant passwordless `sudo` access to particular
commands, and the terminal is the appropriate place to request a password
when one is needed.

Use `pkexec` only when the caller cannot interact with a terminal or cannot
enter a password there, such as a command launched by an agent or a graphical
background process. Do not replace `sudo` with `pkexec` merely because a
command changes system state.

## System Architecture

Omnixy is built on:

| Component | Purpose | Config Location |
|-----------|---------|-----------------|
| **Arch Linux** | Base OS | `/etc/`, `~/.config/` |
| **Hyprland** | Wayland compositor/WM | `~/.config/hypr/` |
| **Omnixy shell** | Status bar + notifications (Quickshell) | `~/.config/omnixy/shell.json` |
| **Launcher/menus** | Quickshell menu | `~/.config/omnixy/extensions/omnixy-menu.jsonc` |
| **Alacritty/Foot/Kitty/Ghostty** | Terminals | `~/.config/<terminal>/` |
| **Omnixy OSD** | On-screen display | Quickshell plugin |

## Command Discovery

Omnixy ships a single `omnixy` CLI that dispatches to all `omnixy-*` binaries via `omnixy <group> <action>`. Always prefer this form — it is self-documenting and stable. The underlying `omnixy-*` binaries still exist on `PATH` and remain safe to read for source.

```bash
# List every documented command and its summary (--all includes hidden commands)
omnixy commands

# Show the commands inside a group
omnixy theme --help
omnixy refresh --help
omnixy restart --help

# Show help for a specific command (does not execute it)
omnixy theme set --help

# Machine-readable listing (binary, route, summary, args, aliases)
omnixy commands --json

# Read a command's source to understand it
cat $(which omnixy-theme-set)
```

### Command Groups

Run `omnixy --help` for the full list. The most common groups:

| Group | Purpose | Example |
|-------|---------|---------|
| `omnixy refresh` | Reset config to defaults (backs up first) | `omnixy refresh shell` |
| `omnixy restart` | Restart a service/app | `omnixy restart shell` |
| `omnixy toggle` | Toggle feature on/off | `omnixy toggle nightlight` |
| `omnixy theme` | Theme management | `omnixy theme set <name>` |
| `omnixy bar` | Bar layout and widgets | `omnixy bar move omnixy.clock --section right` |
| `omnixy plugin` | Manage/clone shell plugins | `omnixy plugin clone omnixy.clock` |
| `omnixy hook` | Install automation hooks | `omnixy hook install theme-set <script>` |
| `omnixy install` | Install optional software / packages | `omnixy install docker dbs` |
| `omnixy launch` | Launch apps | `omnixy launch browser` |
| `omnixy capture` | Screenshots and recordings | `omnixy capture screenshot` |
| `omnixy reminder` | Desktop notification reminders | `omnixy reminder 15 "Pickup Jack"` |
| `omnixy pkg` | Package management | `omnixy pkg add <pkg>` |
| `omnixy setup` | Interactive setup wizards | `omnixy setup security fingerprint` |
| `omnixy update` | System updates | `omnixy update` |

## Configuration Locations

Hyprland config lives in `~/.config/hypr/` — see [`hyprland.md`](hyprland.md).
The Omnixy shell (bar, notifications, plugins, idle) is configured in
`~/.config/omnixy/shell.json` — see [`plugins.md`](plugins.md).

### Terminals

```
~/.config/alacritty/alacritty.toml
~/.config/foot/foot.ini
~/.config/kitty/kitty.conf
~/.config/ghostty/config
```

**Command:** `omnixy restart terminal`

### Other Configs

| App | Location |
|-----|----------|
| btop | `~/.config/btop/btop.conf` |
| fastfetch | `/etc/fastfetch/config.jsonc` default; `~/.config/fastfetch/config.jsonc` user override |
| lazygit | `~/.config/lazygit/config.yml` |
| starship | `~/.config/starship.toml` |
| git | `~/.config/git/config` |

## Safe Customization Patterns

### Edit User Config Directly

For simple changes, edit files in `~/.config/`:

```bash
# 1. Read current config
cat ~/.config/hypr/bindings.lua

# 2. Backup before changes
cp ~/.config/hypr/bindings.lua ~/.config/hypr/bindings.lua.bak.$(date +%s)

# 3. Make changes with Edit tool

# 4. Apply changes
# - Hyprland: auto-reloads on save, but MUST validate with `hyprctl reload` and `hyprctl configerrors`
# - Omnixy shell: shell.json and user plugin code under ~/.config/omnixy/plugins/ hot-reload on save
# - Menus/launcher: ~/.config/omnixy/extensions/omnixy-menu.jsonc hot-reloads on save
# - Terminals: apply with `omnixy restart terminal` (reloads running terminals; foot picks changes up in new windows)
```

### Reset to Defaults -- ALWAYS SEEK USER CONFIRMATION BEFORE RUNNING

When customizations go wrong:

```bash
# Reset specific config (creates backup automatically)
omnixy refresh shell
omnixy refresh hyprland

# The refresh command:
# 1. Backs up current config with timestamp
# 2. Copies default from $OMNIXY_PATH/config/
# 3. Restarts the component where the refresh needs it (e.g. `refresh shell`)
```

## System Commands

```bash
omnixy update                  # Full system update
omnixy version                 # Show Omnixy version
omnixy debug --no-sudo --print # Debug info (ALWAYS use these flags)
omnixy system lock             # Lock screen
omnixy system shutdown         # Shutdown
omnixy system reboot           # Reboot
```

**IMPORTANT:** Always run `omnixy debug` with `--no-sudo --print` flags to avoid interactive sudo prompts that will hang the terminal.

## Troubleshooting

```bash
# Get debug information (ALWAYS use these flags to avoid interactive prompts)
omnixy debug --no-sudo --print

# Reset specific config to defaults
omnixy refresh <app>

# Refresh specific config file
# config-file path is relative to ~/.config/
# eg. `omnixy refresh config hypr/hyprland.lua` will refresh ~/.config/hypr/hyprland.lua
omnixy refresh config <config-file>

# Full reinstall of configs (nuclear option)
omnixy reinstall
```

## Decision Framework

When user requests system changes:

1. **Is it a stock omnixy command?** Use it directly
2. **Is it a config edit?** Edit in `~/.config/`, never `/usr/share/omnixy/`
3. **Is it a theme customization?** Follow [`theming.md`](theming.md); create a NEW custom theme directory
4. **Is it automation?** Follow [`hooks.md`](hooks.md); use `omnixy hook install` and the hook `.d` directories
5. **Is it a package install?** Use `omnixy pkg add <pkgs...>` (or `omnixy pkg aur add <pkgs...>` for AUR-only packages)
6. **Is it built-in shell/plugin code?** Follow [`plugins.md`](plugins.md); clone it with `omnixy plugin clone`, never edit the packaged copy
7. **Unsure if command exists?** Run `omnixy commands` (or `omnixy <group> --help` for one group)

### Reminder Requests

When the user asks to set a reminder, use `omnixy reminder <minutes> [message]` directly. Convert natural language durations to minutes and title-case short reminder labels when appropriate.

```bash
omnixy reminder 15 "Pickup Jack"
omnixy reminder 60 "Check laundry"
omnixy reminder show
omnixy reminder clear
```

## Out of Scope

This skill intentionally does not cover Omnixy source development. Do not use this skill for:
- Editing files in `/usr/share/omnixy/` (`bin/`, `config/`, `default/`, `shell/`, `themes/`, `migrations/`, etc.)
- Creating or editing migrations
- Running `omnixy dev ...` commands

## Example Requests

- "Change my theme to catppuccin" -> `omnixy theme set catppuccin`
- "Add a keybinding for Super+E to open file manager" -> Check existing bindings first, call `hl.unbind` if needed, then `o.bind` in `~/.config/hypr/bindings.lua`
- "Configure my external monitor" -> Edit `~/.config/hypr/monitors.lua`
- "Make the window gaps smaller" -> Edit `~/.config/hypr/looknfeel.lua`
- "Turn on night light" -> `omnixy toggle nightlight` (for time-based schedules, edit `~/.config/hypr/hyprsunset.conf` profiles, then `omnixy restart hyprsunset`)
- "Set a reminder to pickup jack in 15 minutes" -> `omnixy reminder 15 "Pickup Jack"`
- "Show my reminders" -> `omnixy reminder show`
- "Clear all reminders" -> `omnixy reminder clear`
- "Customize the catppuccin theme colors" -> Overlay: put an edited `colors.toml` in `~/.config/omnixy/themes/catppuccin/`, then re-apply the theme (see `theming.md`)
- "Run a script every time I change themes" -> Install it with `omnixy hook install theme-set <script>`
- "Change how workspace labels are rendered" -> Clone `omnixy.workspaces`, which switches the bar to `<username>.workspaces`, then edit the clone
- "Lock after ten minutes" -> Set `idle.lock` to `600` in `~/.config/omnixy/shell.json`
- "Reset shell/bar to defaults" -> `omnixy refresh shell`
- "Record my screen" -> `omnixy screenrecord --fullscreen`, then `omnixy screenrecord --stop-recording` (see `capture.md`)
- "Report this bug to Omnixy" -> Gather diagnostics and a capture of the problem, then file it (see `contributing.md`)
