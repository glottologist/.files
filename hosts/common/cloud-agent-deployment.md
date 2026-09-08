# Cloud Agent Host Deployment

Reliant and Defiant embed `homes/jason-cloud` in their NixOS systems. A system
switch therefore activates Jason's terminal and agent environment; no separate
Home Manager command follows it.

The home closure is large enough that remote deployment must measure what the
target lacks rather than compare its free space with the total closure. Run
this block from the configuration checkout, setting `host` to one of the two
accepted names. It builds locally, requires a 5 GiB post-transfer reserve,
copies the closure, preserves the verified first-activation collisions, and
switches the exact path that passed the check.

```bash
set -euo pipefail

host=${host:?set host to reliant or defiant}
case "$host" in
  reliant | defiant) ;;
  *) printf 'Unsupported cloud agent host: %s\n' "$host" >&2; exit 2 ;;
esac

system=$(nix build --impure --no-link --print-out-paths \
  ".#nixosConfigurations.$host.config.system.build.toplevel")
mapfile -t closure < <(nix-store -qR "$system")
mapfile -t missing < <(
  printf '%s\0' "${closure[@]}" \
    | ssh "root@$host" 'xargs -0 -r nix-store --check-validity --print-invalid'
)

if (( ${#missing[@]} > 0 )); then
  required=$(nix path-info --json --json-format 1 "${missing[@]}" \
    | jq '[to_entries[].value.narSize] | add // 0')
else
  required=0
fi
available=$(ssh "root@$host" \
  "df -B1 --output=avail /nix/store | tail -1 | tr -d ' '")
reserve=$((5 * 1024 * 1024 * 1024))

printf 'missing=%d bytes; available=%d bytes; reserve=%d bytes\n' \
  "$required" "$available" "$reserve"
(( required + reserve <= available )) || {
  echo 'Insufficient target space; nothing copied or switched.' >&2
  exit 1
}

nix copy --substitute-on-destination --to "ssh://root@$host" "$system"

ssh "jason@$host" /run/current-system/sw/bin/bash -s <<'REMOTE'
set -euo pipefail
preserve() {
  source=$HOME/$1
  backup=$source.pre-home-manager
  [[ -e $source || -L $source ]] || return 0
  [[ ! -L $source ]] || return 0
  [[ ! -e $backup && ! -L $backup ]] || {
    printf 'Refusing to overwrite existing backup: %s\n' "$backup" >&2
    exit 1
  }
  mv -- "$source" "$backup"
}
preserve .config/fish/config.fish
preserve .config/htop
REMOTE

ssh "root@$host" \
  "nix-env --profile /nix/var/nix/profiles/system --set '$system' \
    && '$system/bin/switch-to-configuration' switch"
```

The capacity failure happens before transfer. If preservation fails, the new
closure may be present but the active system is unchanged. The procedure never
deletes generations or runs garbage collection automatically.

Verify the activated home as root on the target:

```bash
systemctl is-active home-manager-jason
systemctl show home-manager-jason -p Result --value
sudo -iu jason fish -lic \
  'type -q fish ghostty kitty foot atuin starship tmux fastfetch; and functions -q gs git_worktree_create'
```

The three commands must exit zero; the service outputs must be `active` and
`success`.
