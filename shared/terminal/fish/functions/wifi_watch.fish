function wifi_watch -d "Watch wifi signal strength and connection quality"
    echo "Watching WiFi connection (Press Ctrl+C to stop)"
    echo ""

    while true
        clear
        set timestamp (date '+%Y-%m-%d %H:%M:%S')
        echo "=== WiFi Status - $timestamp ==="
        echo ""

        # Get current connection info
        set ssid (nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
        set signal (nmcli -t -f active,signal dev wifi | grep '^yes' | cut -d: -f2)
        set rate (nmcli -t -f active,rate dev wifi | grep '^yes' | cut -d: -f2)
        set device (nmcli -t -f DEVICE,TYPE device | grep ':wifi$' | cut -d: -f1)

        if [ -n "$ssid" ]
            echo "Connected to: $ssid"
            echo "Signal: $signal%"
            echo "Rate: $rate"
            echo "Device: $device"
            echo ""

            # Signal quality indicator
            if [ "$signal" -gt 70 ]
                echo "Quality: ████████░░ Excellent"
            else if [ "$signal" -gt 50 ]
                echo "Quality: ██████░░░░ Good"
            else if [ "$signal" -gt 30 ]
                echo "Quality: ████░░░░░░ Fair"
            else
                echo "Quality: ██░░░░░░░░ Poor"
            end

            echo ""
            echo "Recent connections:"
            nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi | head -5
        else
            echo "⚠️  Not connected to any WiFi network"
        end

        sleep 3
    end
end
