function track-jj-bookmark --argument-names branch_name --description "Track a git branch with jj bookmark"
    if test -z "$branch_name"
        echo "Error: Please provide a branch name"
        return 1
    end
    
    jj bookmark track "$branch_name@origin"
end

