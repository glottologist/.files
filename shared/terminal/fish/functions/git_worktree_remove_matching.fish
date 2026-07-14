function git_worktree_remove_matching
    # Usage:
    #   git_worktree_remove_matching <substring> [--regex|-r] [--dry-run|-n] [--yes|-y] [--no-force] [--prune] [--prune-only]
    #
    # Removes every worktree whose path contains <substring>. Pass --regex to treat
    # the pattern as a regular expression instead of a literal.
    #
    # Notes:
    #   - Removal uses --force by default; pass --no-force to let git refuse dirty trees.
    #   - The main worktree is never a candidate.
    #   - --prune-only needs no pattern.

    set -l pattern ''
    set -l dry_run 0
    set -l assume_yes 0
    set -l use_force 1
    set -l do_prune 0
    set -l prune_only 0
    set -l use_regex 0

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
                case --regex -r
                    set use_regex 1
                case '*'
                    echo "Unknown option: $arg" >&2
                    echo "Usage: git_worktree_remove_matching <substring> [--regex|-r] [--dry-run|-n] [--yes|-y] [--no-force] [--prune] [--prune-only]" >&2
                    return 1
            end
        else if test -z "$pattern"
            set pattern $arg
        else
            echo "Unexpected extra argument: $arg" >&2
            return 1
        end
    end

    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "Not a git repository." >&2
        return 1
    end

    if test $prune_only -eq 1
        if test $dry_run -eq 1
            echo "(dry-run) Would run: git worktree prune"
            return 0
        end
        git worktree prune
        or begin
            echo "Prune failed." >&2
            return 1
        end
        echo "Prune complete."
        return 0
    end

    if test -z "$pattern"
        echo "Usage: git_worktree_remove_matching <substring> [--regex|-r] [--dry-run|-n] [--yes|-y] [--no-force] [--prune] [--prune-only]" >&2
        return 1
    end

    set -l here (git rev-parse --show-toplevel 2>/dev/null)

    # Parse `git worktree list --porcelain` properly. Records are separated by a blank
    # line, but fish's command substitution has already split the output on newlines, so
    # we accumulate fields as we go and flush on each new `worktree` header. The previous
    # version tried to split an already-split list on \n\n, which silently produced one
    # record per LINE — every worktree came out labelled DETACHED and no lock was ever seen.
    set -l all_paths
    set -l all_labels
    set -l all_locked

    set -l cur_path ''
    set -l cur_branch ''
    set -l cur_head ''
    set -l cur_lock 0

    for line in (git worktree list --porcelain)
        set -l wt (string match -r -g '^worktree (.+)$' -- $line)
        if test -n "$wt"
            if test -n "$cur_path"
                set -a all_paths $cur_path
                set -a all_labels (__gwrm_label "$cur_branch" "$cur_head")
                set -a all_locked $cur_lock
            end
            set cur_path $wt
            set cur_branch ''
            set cur_head ''
            set cur_lock 0
            continue
        end

        set -l br (string match -r -g '^branch (.+)$' -- $line)
        if test -n "$br"
            set cur_branch (string replace -r '^refs/heads/' '' -- $br)
            continue
        end

        set -l hd (string match -r -g '^HEAD ([0-9a-f]+)$' -- $line)
        if test -n "$hd"
            set cur_head $hd
            continue
        end

        if string match -q 'locked*' -- $line
            set cur_lock 1
        end
    end

    if test -n "$cur_path"
        set -a all_paths $cur_path
        set -a all_labels (__gwrm_label "$cur_branch" "$cur_head")
        set -a all_locked $cur_lock
    end

    if test (count $all_paths) -eq 0
        echo "No worktrees found." >&2
        return 1
    end

    # git always lists the main worktree first, so index 1 is the one we must never touch.
    # The old code compared against `git rev-parse --show-toplevel`, which is the worktree
    # you are STANDING IN — so running it from a linked worktree skipped itself and offered
    # up the main repository instead.
    set -l main_path $all_paths[1]

    set -l paths
    set -l labels
    set -l locked

    for i in (seq (count $all_paths))
        set -l p $all_paths[$i]
        test "$p" = "$main_path"; and continue

        if test $use_regex -eq 1
            string match -qr -- $pattern $p; or continue
        else
            string match -q -- "*$pattern*" $p; or continue
        end

        set -a paths $p
        set -a labels $all_labels[$i]
        set -a locked $all_locked[$i]
    end

    if test (count $paths) -eq 0
        echo "No worktrees matched: $pattern"
        return 0
    end

    echo "Matched worktrees:"
    for i in (seq (count $paths))
        set -l note ''
        test $locked[$i] -eq 1; and set note "  [LOCKED]"
        test "$paths[$i]" = "$here"; and set note "$note  [you are here]"
        echo "  $paths[$i]  ($labels[$i])$note"
    end

    if test $dry_run -eq 1
        set -l flags
        test $use_force -eq 1; and set flags ' --force'
        for p in $paths
            echo "(dry-run) Would run: git worktree remove$flags -- \"$p\""
        end
        test $do_prune -eq 1; and echo "(dry-run) Would run: git worktree prune"
        return 0
    end

    if test $assume_yes -ne 1
        set -l what "Remove "(count $paths)" worktree(s)"
        test $use_force -eq 1; and set what "$what with --force"
        read -l -P "$what? [y/N] " reply
        if not string match -qr '^[Yy]([Ee][Ss])?$' -- "$reply"
            echo "Aborted."
            return 1
        end
    end

    set -l rmflags
    test $use_force -eq 1; and set rmflags --force

    set -l failures 0
    for i in (seq (count $paths))
        echo "Removing $paths[$i] ($labels[$i]) ..."
        if not git worktree remove $rmflags -- "$paths[$i]"
            set failures (math $failures + 1)
        end
    end

    if test $do_prune -eq 1
        git worktree prune; and echo "Prune complete."
    end

    if test $failures -gt 0
        echo "$failures removal(s) failed." >&2
        return 1
    end

    echo "Removed "(count $paths)" worktree(s)."
end

function __gwrm_label --argument-names branch head
    if test -n "$branch"
        echo "branch: $branch"
    else if test -n "$head"
        echo "detached: "(string sub -s 1 -l 7 -- $head)
    else
        echo detached
    end
end
