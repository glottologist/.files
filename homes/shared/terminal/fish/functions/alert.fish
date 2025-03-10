function alert
    if test (count $argv) -lt 2
        echo "Usage: alert <topic> <message>"
        return 1
    end
    set topic $argv[1]
    set message (string join " " $argv[2..-1])
    curl -X POST "http://valiant:81/$topic" -d "$message"
end
