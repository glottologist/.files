function pr_worktree
    set -l usage "Usage: pr_worktree <PR_number>"
    if test (count $argv) -lt 1
        echo $usage
        return 1
    end

    set -l pr_number $argv[1]
    if not string match -qr '^[0-9]+$' -- $pr_number
        echo "PR number must be numeric"
        return 1
    end

    # --- deps ---
    if not type -q git
        echo "git not found in PATH"
        return 1
    end
    if not type -q gh
        echo "gh (GitHub CLI) not found in PATH"
        return 1
    end

    # --- in repo? ---
    git rev-parse --git-dir >/dev/null 2>&1
    if test $status -ne 0
        echo "Not inside a git repository"
        return 1
    end

    # --- check PR exists/accessible (better error early) ---
    gh pr view $pr_number >/dev/null 2>&1
    if test $status -ne 0
        echo "PR #$pr_number not found or not accessible"
        return 1
    end

    # --- paths ---
    set -l worktree_root ./prs
    set -l worktree_path "$worktree_root/$pr_number"

    # Ensure prs/ exists
    if not test -d "$worktree_root"
        mkdir -p "$worktree_root"; or begin
            echo "Failed to create $worktree_root"
            return 1
        end
    end

    # Avoid clobber
    if test -e "$worktree_path"
        echo "Worktree already exists at $worktree_path"
        return 1
    end

    # --- create detached worktree ---
    echo "Creating worktree for PR #$pr_number at $worktree_path..."
    git worktree add --detach "$worktree_path" >/dev/null 2>&1
    if test $status -ne 0
        echo "Failed to create worktree"
        return 1
    end

    # --- checkout PR in that worktree (no subshell) ---
    pushd "$worktree_path" >/dev/null
    echo "Checking out PR #$pr_number..."
    gh pr checkout $pr_number >/dev/null 2>&1
    set -l checkout_status $status
    popd >/dev/null

    if test $checkout_status -ne 0
        echo "Failed to checkout PR; removing worktree…"
        # Remove both the worktree registration and dir
        git worktree remove --force "$worktree_path" >/dev/null 2>&1
        return 1
    end

    echo "✓ PR #$pr_number ready at $worktree_path"
end

