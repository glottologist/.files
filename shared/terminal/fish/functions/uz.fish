function uz
    set -l target_dir $argv[1]
    
    if test -z "$target_dir"
        echo "Usage: unzip-all /path/to/target/folder"
        return 1
    end
    
    if not test -d "$target_dir"
        mkdir -p "$target_dir"
    end
    
    find . -name "*.zip" -exec unzip -o {} -d "$target_dir" \;
    
    echo "All zip files extracted to $target_dir"
end
