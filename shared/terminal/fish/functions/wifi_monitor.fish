function wifi_monitor -d "Monitor wifi connectivity and log disconnections"
    set log_file "$HOME/.wifi_monitor.log"
    set -q argv[1]; and set log_file $argv[1]

    echo "Starting wifi monitor - logging to $log_file"
    echo "Press Ctrl+C to stop"
    echo ""

    # Log start time
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Monitoring started" >> $log_file

    set previous_state ""
    set previous_ssid ""

    while true
        set current_state (nmcli -t -f STATE general)
        set connection_status (nmcli radio wifi)
        set connected_ssid (nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)

        # Check if wifi is connected
        if [ "$connection_status" = "enabled" ]
            if [ -n "$connected_ssid" ]
                # Connected
                if [ "$previous_state" != "connected" ]
                    set timestamp (date '+%Y-%m-%d %H:%M:%S')
                    set message "[$timestamp] ✓ WiFi CONNECTED to: $connected_ssid"
                    echo $message
                    echo $message >> $log_file
                    set previous_state "connected"
                    set previous_ssid "$connected_ssid"
                end
            else
                # Wifi enabled but not connected
                if [ "$previous_state" != "disconnected" ]
                    set timestamp (date '+%Y-%m-%d %H:%M:%S')
                    set prev_msg ""
                    [ -n "$previous_ssid" ]; and set prev_msg " (was: $previous_ssid)"
                    set message "[$timestamp] ✗ WiFi DISCONNECTED$prev_msg"
                    echo $message
                    echo $message >> $log_file
                    set previous_state "disconnected"
                end
            end
        else
            # Wifi disabled
            if [ "$previous_state" != "disabled" ]
                set timestamp (date '+%Y-%m-%d %H:%M:%S')
                set message "[$timestamp] ⊗ WiFi DISABLED"
                echo $message
                echo $message >> $log_file
                set previous_state "disabled"
            end
        end

        sleep 2
    end
end
