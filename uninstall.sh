#!/bin/sh

UDEV_RULE="/etc/udev/rules.d/99-lian-li-fans.rules"
LOCK_FILE="/tmp/fan_speed_control.lock"

# Stop the fan control process if running
if pgrep -x fan_speed_control > /dev/null; then
    echo "Stopping fan_speed_control..."
    sudo pkill -x fan_speed_control
    sleep 1
fi

# Remove lock file
if [ -f "$LOCK_FILE" ]; then
    echo "Removing lock file..."
    sudo rm -f "$LOCK_FILE"
fi

# Remove binary from /usr/local/bin
if [ -f "/usr/local/bin/fan_speed_control" ]; then
    echo "Removing binary from /usr/local/bin..."
    sudo rm -f /usr/local/bin/fan_speed_control
fi

# Remove udev rule
if [ -f "$UDEV_RULE" ]; then
    echo "Removing udev rule..."
    sudo rm -f "$UDEV_RULE"
    sudo udevadm control --reload
fi

echo "fan_speed_control uninstalled."
