function issue
    set -l usage "Usage: issue <issue_number>"

    if test (count $argv) -lt 1
        echo $usage >&2
        return 1
    end

    set -l issue_number $argv[1]
    if not string match -qr '^[0-9]+$' -- "$issue_number"
        echo "[ERROR] Issue number must be numeric: '$issue_number'" >&2
        return 1
    end

    if not type -q git
        echo "[ERROR] git not found in PATH" >&2
        return 127
    end
    if not type -q gh
        echo "[ERROR] gh (GitHub CLI) not found in PATH" >&2
        return 127
    end
    if not type -q jq
        echo "[ERROR] jq not found in PATH" >&2
        return 127
    end

    git rev-parse --is-inside-work-tree >/dev/null 2>&1; or begin
        echo "[ERROR] Not inside a git repository" >&2
        return 1
    end

    echo "[INFO] Fetching issue #$issue_number..."
    set -l issue_json (gh issue view "$issue_number" --json title,body,comments,author,labels,state,createdAt,url 2>&1)
    if test $status -ne 0
        echo "[ERROR] Failed to fetch issue #$issue_number" >&2
        echo "$issue_json" >&2
        return 1
    end

    set -l raw_title (echo "$issue_json" | jq -r '.title')
    if test -z "$raw_title" -o "$raw_title" = "null"
        echo "[ERROR] Could not read issue title" >&2
        return 1
    end

    set -l slug (echo "$raw_title" | string lower | string replace -ra '[^a-z0-9]+' '-' | string trim --chars='-' | string sub -l 60 | string replace -r -- '-+$' '')
    set -l branch_name "jason/$slug"
    set -l worktree_path "./worktrees/$branch_name"

    echo "[INFO] Branch: $branch_name"
    echo "[INFO] Worktree: $worktree_path"

    if test -d "$worktree_path"
        echo "[ERROR] Worktree already exists at $worktree_path" >&2
        return 1
    end

    mkdir -p (dirname "$worktree_path"); or begin
        echo "[ERROR] Failed to create parent directory for $worktree_path" >&2
        return 1
    end

    set -l default_branch (git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | string replace 'refs/remotes/origin/' '')
    if test -z "$default_branch"
        set default_branch main
    end

    echo "[INFO] Creating branch '$branch_name' from '$default_branch'..."

    if git show-ref --verify --quiet "refs/heads/$branch_name"
        echo "[INFO] Removing existing local branch '$branch_name'..."
        git branch -D "$branch_name" >/dev/null 2>&1
    end

    git fetch origin "$default_branch" >/dev/null 2>&1

    git worktree add -b "$branch_name" "$worktree_path" "origin/$default_branch"; or begin
        echo "[ERROR] Failed to create worktree/branch '$branch_name'" >&2
        return 1
    end

    echo "[INFO] Pushing branch '$branch_name' to origin..."
    git -C "$worktree_path" push -u origin "$branch_name"; or begin
        echo "[ERROR] Failed to push '$branch_name' to origin" >&2
        return 1
    end

    echo "[INFO] Creating issue document..."

    set -l claude_dir "$worktree_path/claude"
    mkdir -p "$claude_dir"; or begin
        echo "[ERROR] Failed to create $claude_dir" >&2
        return 1
    end

    set -l issue_file "$claude_dir/issue.md"
    set -l issue_url (echo "$issue_json" | jq -r '.url')
    set -l issue_state (echo "$issue_json" | jq -r '.state')
    set -l issue_author (echo "$issue_json" | jq -r '.author.login')
    set -l issue_created (echo "$issue_json" | jq -r '.createdAt')
    set -l issue_labels (echo "$issue_json" | jq -r '[.labels[].name] | join(", ")')
    set -l issue_body (echo "$issue_json" | jq -r '.body // ""')
    set -l comment_count (echo "$issue_json" | jq '.comments | length')

    echo "# Issue #$issue_number: $raw_title" > "$issue_file"
    echo "" >> "$issue_file"
    echo "- **URL:** $issue_url" >> "$issue_file"
    echo "- **State:** $issue_state" >> "$issue_file"
    echo "- **Author:** $issue_author" >> "$issue_file"
    echo "- **Created:** $issue_created" >> "$issue_file"
    if test -n "$issue_labels" -a "$issue_labels" != ""
        echo "- **Labels:** $issue_labels" >> "$issue_file"
    end
    echo "" >> "$issue_file"
    echo "## Description" >> "$issue_file"
    echo "" >> "$issue_file"
    if test -n "$issue_body"
        echo "$issue_body" >> "$issue_file"
    else
        echo "_No description provided._" >> "$issue_file"
    end
    echo "" >> "$issue_file"

    if test "$comment_count" -gt 0
        echo "## Comments ($comment_count)" >> "$issue_file"
        echo "" >> "$issue_file"

        for i in (seq 0 (math "$comment_count - 1"))
            set -l c_author (echo "$issue_json" | jq -r ".comments[$i].author.login")
            set -l c_created (echo "$issue_json" | jq -r ".comments[$i].createdAt")
            set -l c_body (echo "$issue_json" | jq -r ".comments[$i].body")
            echo "### $c_author ($c_created)" >> "$issue_file"
            echo "" >> "$issue_file"
            echo "$c_body" >> "$issue_file"
            echo "" >> "$issue_file"
        end
    end

    echo "✓ Worktree for issue #$issue_number created at $worktree_path"
    echo "✓ Issue document written to $issue_file"
end
