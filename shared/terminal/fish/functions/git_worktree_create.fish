function git_worktree_create
    if test (count $argv) -lt 1
        echo "Usage: git_worktree_create <branch_name> [start_point]"
        return 1
    end

    set -l branch_name $argv[1]
    set -l worktree_path "./worktrees/$branch_name"
    set -l start_point
    set -q argv[2]; and set start_point $argv[2]

    if test -d "$worktree_path"
        echo "Worktree already exists at $worktree_path"
        return 1
    end

    # Ensure parent directory exists
    mkdir -p (dirname "$worktree_path"); or begin
        echo "Failed to create parent directory for $worktree_path"
        return 1
    end

    set -l created_branch 0

    if git show-ref --verify --quiet "refs/heads/$branch_name"
        # Local branch exists: just add the worktree
        echo "Creating worktree for existing branch '$branch_name'..."
        git worktree add "$worktree_path" "$branch_name"; or begin
            echo "Failed to create worktree for branch '$branch_name'"
            return 1
        end
    else if test -n "$start_point"
        # No local branch; create new branch at start_point via worktree directly
        echo "Creating new branch '$branch_name' at '$start_point' in a worktree..."
        git worktree add -b "$branch_name" "$worktree_path" "$start_point"; or begin
            echo "Failed to create worktree/branch '$branch_name' at '$start_point'"
            return 1
        end
        set created_branch 1
    else
        # Try to base local branch on origin/$branch_name
        echo "Branch '$branch_name' not local; checking remote 'origin/$branch_name'..."
        git ls-remote --exit-code --heads origin "$branch_name" >/dev/null; or begin
            echo "Remote branch 'origin/$branch_name' not found and no start_point provided."
            return 1
        end

        echo "Fetching 'origin/$branch_name'..."
        git fetch origin "$branch_name"; or begin
            echo "Failed to fetch 'origin/$branch_name'"
            return 1
        end

        echo "Creating local tracking branch '$branch_name' from 'origin/$branch_name'..."
        git branch --track "$branch_name" "origin/$branch_name"; or begin
            echo "Failed to create local branch from origin/$branch_name"
            return 1
        end
        set created_branch 1

        echo "Creating worktree for branch '$branch_name'..."
        git worktree add "$worktree_path" "$branch_name"; or begin
            echo "Failed to create worktree for branch '$branch_name'; cleaning up created branch..."
            git branch -D "$branch_name" >/dev/null 2>&1
            return 1
        end
    end

    echo "✓ Worktree for branch '$branch_name' created at $worktree_path"
end

