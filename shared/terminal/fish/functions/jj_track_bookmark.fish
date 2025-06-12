function jj_track_bookmark
    if test (count $argv) -lt 1
        echo "Usage: track_jj_bookmark <branch_name>"
        return 1
    end
    set branch_name $argv[1]
    
    jj bookmark track "$branch_name@origin"
end

