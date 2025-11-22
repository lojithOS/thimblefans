#!/bin/sh

SERVICE_NAME="s6-fan_speed_control"
SERVICE_DIR="/etc/s6/services/$SERVICE_NAME"
SRC_DIR="$(pwd)/$SERVICE_NAME"

# Create service directory and run script
if [ ! -d "$SRC_DIR" ]; then
    mkdir -p "$SRC_DIR"
fi
cat > "$SRC_DIR/run" <<'EOF'
#!/bin/sh
exec /home/lojith/Documents/Github/thimblefans/fan_speed_control
EOF
chmod +x "$SRC_DIR/run"

# Create service directory in /etc/s6/services
if [ ! -d "$SERVICE_DIR" ]; then
    sudo mkdir -p "$SERVICE_DIR"
fi

# Copy run script
sudo cp "$SRC_DIR/run" "$SERVICE_DIR/run"

# Make run script executable
sudo chmod +x "$SERVICE_DIR/run"

echo "Service installed at $SERVICE_DIR."

# Prompt to enable service
echo -n "Enable $SERVICE_NAME service now? (y/n): "
read yn
if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
    sudo s6-svscan /etc/s6/services &
    echo "$SERVICE_NAME enabled."
else
    echo "Service not enabled."
fi
