function git_worktree_remove_matching
    # Usage:
    #   git_worktree_remove_matching <path-regex> [--dry-run|-n] [--yes|-y] [--no-force]
    if test (count $argv) -lt 1
        echo "Usage: git_worktree_remove_matching <path-regex> [--dry-run|-n] [--yes|-y] [--no-force]"
        return 1
    end

    set -l regex $argv[1]
    set -l dry_run 0
    set -l assume_yes 0
    set -l use_force 1  # default: force removal

    for arg in $argv[2..-1]
        switch $arg
            case --dry-run -n
                set dry_run 1
            case --yes -y
                set assume_yes 1
            case --no-force
                set use_force 0
        end
    end

    # Ensure we're in a git repo
    git rev-parse --git-dir &>/dev/null
    if test $status -ne 0
        echo "Not a git repository."
        return 1
    end

    set -l toplevel (git rev-parse --show-toplevel 2>/dev/null)

    # Parse worktrees (path + branch) from porcelain output, block by block
    set -l blocks (git worktree list --porcelain)
    set -l blocks (string split -m 0 \n\n -- $blocks)

    set -l match_paths
    set -l match_branches

    for block in $blocks
        set -l path (string match -r -g '^worktree (.+)$' -- $block)
        if test -z "$path"
            continue
        end

        # Skip the primary worktree
        if test "$path" = "$toplevel"
            continue
        end

        # Determine branch label (strip refs/heads/ if present)
        set -l branch (string match -r -g '^branch (.+)$' -- $block)
        if test -n "$branch"
            set branch (string replace -r '^refs/heads/' '' -- $branch)
        else if string match -q '*detached*' -- $block
            set branch 'DETACHED'
        else
            set branch 'UNKNOWN'
        end

        # Apply path regex filter
        if string match -r -- $regex $path &>/dev/null
            set match_paths $match_paths $path
            set match_branches $match_branches $branch
        end
    end

    if test (count $match_paths) -eq 0
        echo "No worktrees matched regex: $regex"
        return 0
    end

    echo "Matched worktrees:"
    for i in (seq (count $match_paths))
        set -l p $match_paths[$i]
        set -l b $match_branches[$i]
        echo "  $p  (branch: $b)"
    end

    if test $dry_run -eq 1
        if test $use_force -eq 1
            echo "(dry-run) Would remove the above worktrees with --force"
        else
            echo "(dry-run) Would remove the above worktrees without --force"
        end
        return 0
    end

    if test $assume_yes -ne 1
        if test $use_force -eq 1
            read -l -P "Remove these worktrees with --force? [y/N] " reply
        else
            read -l -P "Remove these worktrees (no --force)? [y/N] " reply
        end
        switch $reply
            case y Y yes YES
                # proceed
            case '*'
                echo "Aborted."
                return 1
        end
    end

    for i in (seq (count $match_paths))
        set -l p $match_paths[$i]
        set -l b $match_branches[$i]
        set -l rmflags
        if test $use_force -eq 1
            set rmflags --force
        end

        echo "Removing $p (branch: $b) ..."
        git worktree remove $rmflags -- "$p"
        if test $status -ne 0
            echo "Failed to remove $p"
        end
    end
end

