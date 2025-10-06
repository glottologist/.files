function git_worktree_remove_matching
    # Usage:
    #   git_worktree_remove_matching <path-regex> [--dry-run|-n] [--yes|-y] [--no-force] [--prune] [--prune-only]
    # Notes:
    #   - By default, removal uses --force.
    #   - You may run prune-only without a regex: git_worktree_remove_matching --prune-only

    set -l regex ''
    set -l dry_run 0
    set -l assume_yes 0
    set -l use_force 1
    set -l do_prune 0
    set -l prune_only 0

    # Parse args: allow flags in any order; first non-flag is regex
    for arg in $argv
        if string match -q -- '-*' $arg
            switch $arg
                case --dry-run -n
                    set dry_run 1
                case --yes -y
                    set assume_yes 1
                case --no-force
                    set use_force 0
                case --prune
                    set do_prune 1
                case --prune-only
                    set do_prune 1
                    set prune_only 1
                case '*'
                    echo "Unknown option: $arg"
                    echo "Usage: git_worktree_remove_matching <path-regex> [--dry-run|-n] [--yes|-y] [--no-force] [--prune] [--prune-only]"
                    return 1
            end
        else
            if test -z "$regex"
                set regex $arg
            else
                echo "Unexpected extra positional argument: $arg"
                echo "Usage: git_worktree_remove_matching <path-regex> [--dry-run|-n] [--yes|-y] [--no-force] [--prune] [--prune-only]"
                return 1
            end
        end
    end

    # Ensure we're in a git repo
    git rev-parse --is-inside-work-tree &>/dev/null
    if test $status -ne 0
        echo "Not a git repository."
        return 1
    end

    # Handle prune-only early (no regex needed)
    if test "$prune_only" = "1"
        echo "Pruning stale worktree metadata..."
        if test $dry_run -eq 1
            echo "(dry-run) Would run: git worktree prune"
        else
            git worktree prune
            if test $status -eq 0
                echo "✅ Prune complete."
            else
                echo "⚠️  Prune failed."
                return 1
            end
        end
        return 0
    end

    # Require regex for removal mode
    if test -z "$regex"
        echo "Usage: git_worktree_remove_matching <path-regex> [--dry-run|-n] [--yes|-y] [--no-force] [--prune] [--prune-only]"
        return 1
    end

    set -l toplevel (git rev-parse --show-toplevel 2>/dev/null)

    # Parse worktrees from porcelain output (path, branch/HEAD, locked)
    set -l raw (git worktree list --porcelain)
    set -l blocks (string split -m 0 \n\n -- $raw)

    set -l match_paths
    set -l match_labels
    set -l match_locked

    for block in $blocks
        set -l path (string match -r -g '^worktree (.+)$' -- $block)
        if test -z "$path"
            continue
        end

        # Skip the primary worktree
        if test "$path" = "$toplevel"
            continue
        end

        # Branch label
        set -l branch (string match -r -g '^branch (.+)$' -- $block)
        if test -n "$branch"
            set branch (string replace -r '^refs/heads/' '' -- $branch)
        else
            # Detached: try to pull short HEAD from porcelain, else query the worktree directly
            set -l head (string match -r -g '^HEAD ([0-9a-f]+)$' -- $block)
            if test -n "$head"
                set branch "DETACHED@(string sub -s 1 -l 7 $head)"
            else
                set -l sha (git -C "$path" rev-parse --short HEAD ^/dev/null 1>/dev/null; and git -C "$path" rev-parse --short HEAD 2>/dev/null)
                if test -n "$sha"
                    set branch "DETACHED@$sha"
                else
                    set branch "DETACHED"
                end
            end
        end

        # Locked?
        set -l is_locked 0
        if string match -qr '^locked' -- $block
            set is_locked 1
        end

        # Apply regex to path
        if string match -r -- $regex $path &>/dev/null
            set match_paths   $match_paths   $path
            set match_labels  $match_labels  $branch
            set match_locked  $match_locked  $is_locked
        end
    end

    if test (count $match_paths) -eq 0
        echo "No worktrees matched regex: $regex"
        return 0
    end

    echo "Matched worktrees:"
    for i in (seq (count $match_paths))
        set -l p $match_paths[$i]
        set -l b $match_labels[$i]
        set -l lockflag $match_locked[$i]

        if test "$lockflag" = "1"
            echo "  ⚠️  $p  (branch: $b, LOCKED)"
            echo "     → This worktree is locked and will only be removed because --force is the default."
        else
            echo "  $p  (branch: $b)"
        end
    end

    if test $dry_run -eq 1
        for i in (seq (count $match_paths))
            set -l p $match_paths[$i]
            set -l b $match_labels[$i]
            set -l lockflag $match_locked[$i]
            set -l cmd "git worktree remove"
            if test $use_force -eq 1
                set cmd "$cmd --force"
            end
            if test "$lockflag" = "1"
                echo "(dry-run) Would run: $cmd -- \"$p\"    # $b [locked]"
            else
                echo "(dry-run) Would run: $cmd -- \"$p\"    # $b"
            end
        end
        if test $do_prune -eq 1
            echo "(dry-run) Would run: git worktree prune"
        end
        return 0
    end

    if test $assume_yes -ne 1
        set -l prompt "Remove these worktrees"
        if test $use_force -eq 1
            set prompt "$prompt with --force"
        end
        read -l -P "$prompt? [y/N] " reply
        switch $reply
            case y Y yes YES
                # proceed
            case '*'
                echo "Aborted."
                return 1
        end
    end

    set -l failures 0
    for i in (seq (count $match_paths))
        set -l p $match_paths[$i]
        set -l b $match_labels[$i]
        set -l rmflags
        if test $use_force -eq 1
            set rmflags --force
        end
        echo "Removing $p (branch: $b) ..."
        git worktree remove $rmflags -- "$p"
        if test $status -ne 0
            echo "Failed to remove $p"
            set failures (math $failures + 1)
        end
    end

    if test $do_prune -eq 1
        echo "Pruning stale worktree metadata..."
        git worktree prune
        if test $status -ne 0
            echo "⚠️  Prune failed."
        else
            echo "✅ Prune complete."
        end
    end

    if test $failures -gt 0
        echo "$failures removal(s) failed."
        return 1
    end

    echo "Done."
end

