function rgmatch
    # Check if at least two arguments are provided
    if test (count $argv) -lt 2
        echo "Usage: rgmatch INCLUDE_PATTERN EXCLUDE_PATTERN [PATH]"
        echo "Example: rgmatch \"(carrot|potato)\" \"grape\" ~/documents"
        return 1
    end
    
    set include_pattern $argv[1]
    set exclude_pattern $argv[2]
    
    # Default path is current directory if not specified
    if test (count $argv) -gt 2
        set search_path $argv[3..-1]
    else
        set search_path "."
    end
    
    # Execute ripgrep command with the patterns
    # Include what matches first pattern, exclude what matches second pattern
    rg $include_pattern $search_path --regexp $exclude_pattern -v
end
