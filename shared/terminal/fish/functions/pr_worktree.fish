function pr_worktree
    set -l usage "Usage: pr_worktree [--root DIR] [--repo OWNER/REPO] [--force] <PR_number>"

    # ---- defaults ----
    set -l root "./prs"
    set -l repo ""
    set -l force 0
    set -l positionals

    # ---- parse flags ----
    if type -q argparse
        argparse -n pr_worktree 'h/help' 'root=' 'repo=' 'force' -- $argv
        or begin
            echo $usage >&2
            return 2
        end
        if set -q _flag_help
            echo $usage
            return 0
        end
        if set -q _flag_root
            set root $_flag_root
        end
        if set -q _flag_repo
            set repo $_flag_repo
        end
        if set -q _flag_force
            set force 1
        end
        set positionals $argv
    else
        set positionals $argv
    end

    # ---- argument validation ----
    if test (count $positionals) -lt 1
        echo $usage >&2
        return 1
    end
    set -l pr_number $positionals[1]
    if not string match -qr '^[0-9]+$' -- "$pr_number"
        echo "PR number must be numeric" >&2
        return 1
    end

    # ---- deps ----
    if not type -q git
        echo "git not found in PATH" >&2
        return 127
    end
    if not type -q gh
        echo "gh (GitHub CLI) not found in PATH" >&2
        return 127
    end

    # ---- determine repo ----
    set -l repo_args
    if test -n "$repo"
        set repo_args --repo "$repo"
    else
        git rev-parse --is-inside-work-tree >/dev/null 2>&1
        or begin
            echo "Not inside a git repository and no --repo specified" >&2
            return 1
        end
        set -l inferred_repo (gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null)
        if test -n "$inferred_repo" -a "$inferred_repo" != "null"
            set repo_args --repo "$inferred_repo"
        end
    end

    # ---- early PR existence & metadata ----
    gh pr view $pr_number $repo_args >/dev/null 2>&1
    or begin
        echo "PR #$pr_number not found or not accessible" >&2
        return 1
    end
    set -l head_branch (gh pr view $pr_number $repo_args --json headRefName --jq .headRefName 2>/dev/null)
    if test "$head_branch" = "null"
        set head_branch ""
    end

    # ---- paths ----
    set -l worktree_root "$root"
    set -l worktree_path "$worktree_root/$pr_number"

    if not test -d "$worktree_root"
        mkdir -p "$worktree_root"
        or begin
            echo "Failed to create $worktree_root" >&2
            return 1
        end
    end

    if test -e "$worktree_path"
        if test $force -eq 1
            if test -d "$worktree_path"
                if test -n (ls -A "$worktree_path" 2>/dev/null)
                    echo "Refusing to overwrite non-empty $worktree_path (even with --force)" >&2
                    return 1
                end
            end
            rm -rf "$worktree_path"
            or begin
                echo "Failed to clear $worktree_path" >&2
                return 1
            end
        else
            echo "Worktree already exists at $worktree_path (use --force to overwrite an empty dir)" >&2
            return 1
        end
    end

    # ---- create detached worktree ----
    echo "Creating worktree for PR #$pr_number at $worktree_path..."
    git worktree add --detach -- "$worktree_path" >/dev/null 2>&1
    or begin
        echo "Failed to create worktree" >&2
        return 1
    end

    # ---- checkout PR (with fallbacks) ----
    pushd "$worktree_path" >/dev/null
    if test -n "$head_branch"
        echo "Checking out PR #$pr_number (branch: $head_branch)..."
    else
        echo "Checking out PR #$pr_number..."
    end

    # Fast path: gh handles forks/remotes automatically (when it can)
    gh pr checkout $pr_number $repo_args >/dev/null 2>&1
    set -l checkout_status $status

    if test $checkout_status -ne 0
        # Fallback A: fetch from origin's pull ref
        git fetch origin "pull/$pr_number/head:pr-$pr_number" >/dev/null 2>&1
        if test $status -eq 0
            git checkout "pr-$pr_number" >/dev/null 2>&1
            set checkout_status $status
        end
    end

    if test $checkout_status -ne 0
        # Fallback B: fork PR — add remote and fetch the head branch
        # Try to get a usable clone URL for the head repo (ssh/https/url)
        set -l head_url (gh pr view $pr_number $repo_args --json headRepository --jq '.headRepository.sshUrl // .headRepository.httpsUrl // .headRepository.url' 2>/dev/null)
        if test -n "$head_url" -a "$head_url" != "null"
            set -l remote_name "pr-$pr_number-remote"
            git remote get-url "$remote_name" >/dev/null 2>&1
            or git remote add "$remote_name" "$head_url" >/dev/null 2>&1

            if test -n "$head_branch" -a "$head_branch" != "null"
                git fetch "$remote_name" "$head_branch:pr-$pr_number" >/dev/null 2>&1
                if test $status -eq 0
                    git checkout "pr-$pr_number" >/dev/null 2>&1
                    set checkout_status $status
                    # set upstream (best-effort)
                    git branch --set-upstream-to "$remote_name/$head_branch" "pr-$pr_number" >/dev/null 2>&1
                end
            end
        end
    end
    popd >/dev/null

    if test $checkout_status -ne 0
        echo "Failed to checkout PR; removing worktree…" >&2
        git worktree remove --force -- "$worktree_path" >/dev/null 2>&1
        if test -e "$worktree_path"
            rm -rf "$worktree_path" >/dev/null 2>&1
        end
        echo "Hints:" >&2
        echo "  • Check GitHub auth: gh auth status" >&2
        echo "  • If PR is from a fork and private, you may lack fetch rights." >&2
        echo "  • Try manually: git fetch origin pull/$pr_number/head:pr-$pr_number && git checkout pr-$pr_number" >&2
        return 1
    end

    # ---- final feedback ----
    set -l refdesc (git -C "$worktree_path" rev-parse --abbrev-ref HEAD 2>/dev/null)
    if test -n "$refdesc"
        echo "✓ PR #$pr_number ready at $worktree_path (HEAD: $refdesc)"
    else
        echo "✓ PR #$pr_number ready at $worktree_path"
    end
end

