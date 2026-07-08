function cargo_clean_repos
    # Usage:
    #   cargo_clean_repos [path] [--dry-run|-n]
    #
    # Recursively finds every git repository and worktree under [path]
    # (default: current directory) and runs `cargo clean` on each one that has
    # a Cargo.toml at its root. Both normal repositories (a .git directory) and
    # linked worktrees (a .git file) are detected.

    set -l root .
    set -l dry_run 0

    # Flags in any order; first non-flag positional is the search root.
    for arg in $argv
        if string match -q -- '-*' $arg
            switch $arg
                case --dry-run -n
                    set dry_run 1
                case '*'
                    echo "Unknown option: $arg"
                    echo "Usage: cargo_clean_repos [path] [--dry-run|-n]"
                    return 1
            end
        else
            set root $arg
        end
    end

    if not test -d "$root"
        echo "Not a directory: $root"
        return 1
    end

    set -l cleaned 0
    set -l skipped 0
    set -l failures 0

    # `-name .git` matches both the metadata directory of a normal repo and the
    # .git *file* of a linked worktree. `-prune` stops descent into the metadata
    # directory (fast) but still walks the work tree, so nested repos and
    # worktrees under ./worktrees/ are picked up too.
    for gitpath in (find $root -name .git -prune -print)
        set -l repo (dirname $gitpath)

        if not test -f "$repo/Cargo.toml"
            echo "⏭  skip (no Cargo.toml) → $repo"
            set skipped (math $skipped + 1)
            continue
        end

        if test $dry_run -eq 1
            echo "(dry-run) cargo clean → $repo"
            set cleaned (math $cleaned + 1)
            continue
        end

        echo "🧹 cargo clean → $repo"
        if cargo clean --manifest-path "$repo/Cargo.toml"
            set cleaned (math $cleaned + 1)
        else
            echo "⚠️  cargo clean failed → $repo"
            set failures (math $failures + 1)
        end
    end

    if test $dry_run -eq 1
        echo "✅ Dry run: $cleaned repo(s) would be cleaned, $skipped skipped."
    else
        echo "✅ Done: $cleaned repo(s) cleaned, $skipped skipped, $failures failed."
    end

    test $failures -eq 0
end
