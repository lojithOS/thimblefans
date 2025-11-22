#!/bin/sh

SERVICE_NAME="s6-fan_speed_control"
SERVICE_DIR="/etc/s6/services/$SERVICE_NAME"
SRC_DIR="$(pwd)/$SERVICE_NAME"
LOCK_FILE="/var/run/fan_speed_control.lock"

# Stop the service if running
if [ -d "$SERVICE_DIR" ]; then
    echo "Stopping $SERVICE_NAME service..."
    sudo s6-svscanctl -t /etc/s6/services
    sudo s6-svc -d "$SERVICE_DIR" 2>/dev/null
fi

# Remove service directory
if [ -d "$SERVICE_DIR" ]; then
    echo "Removing $SERVICE_DIR..."
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

echo "$SERVICE_NAME uninstalled."
