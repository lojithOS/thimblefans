#!/bin/sh

SERVICE_NAME="s6-fan_speed_control"
SERVICE_DIR="/etc/s6/services/$SERVICE_NAME"
SRC_DIR="$(pwd)/$SERVICE_NAME"
LOCK_FILE="/var/run/fan_speed_control.lock"

# Stop the service if running
if [ -d "$SERVICE_DIR" ]; then
    echo "Stopping $SERVICE_NAME service..."
    sudo s6-svc -d "$SERVICE_DIR" 2>/dev/null
    sleep 1
fi

# Remove service directory (includes all s6 state files)
if [ -d "$SERVICE_DIR" ]; then
    echo "Removing $SERVICE_DIR and all s6 state files..."
    sudo rm -rf "$SERVICE_DIR"
fi

# Remove local service directory
if [ -d "$SRC_DIR" ]; then
    echo "Removing $SRC_DIR..."
    rm -rf "$SRC_DIR"
fi

# Remove lock file
if [ -f "$LOCK_FILE" ]; then
    echo "Removing lock file $LOCK_FILE..."
    sudo rm -f "$LOCK_FILE"
fi

# Remove binary from /usr/local/bin
if [ -f "/usr/local/bin/fan_speed_control" ]; then
    echo "Removing binary from /usr/local/bin..."
    sudo rm -f /usr/local/bin/fan_speed_control
fi

echo "$SERVICE_NAME uninstalled."
