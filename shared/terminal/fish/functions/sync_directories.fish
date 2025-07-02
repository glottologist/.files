function sync_directories
    # Check if exactly 2 arguments are provided
    if test (count $argv) -ne 2
        echo "Usage: sync_directories <source_path> <destination_path>"
        return 1
    end
    
    set source_path $argv[1]
    set dest_path $argv[2]
    
    # Check if source path exists
    if not test -e $source_path
        echo "Error: Source path '$source_path' does not exist"
        return 1
    end
    
    echo "Syncing from '$source_path' to '$dest_path'..."
    rsync -avh --info=progress2 --progress --stats $source_path $dest_path
end
