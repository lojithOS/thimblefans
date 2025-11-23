#!/bin/sh

SERVICE_NAME="s6-fan_speed_control"
SERVICE_DIR="/etc/s6/services/$SERVICE_NAME"

# Build the binary
echo "Building fan_speed_control..."
make
if [ $? -ne 0 ]; then
    echo "Build failed. Exiting."
    exit 1
fi

# Move binary to /usr/local/bin
echo "Attempting to move binary to /usr/local/bin..."
sudo mv fan_speed_control /usr/local/bin/fan_speed_control
sudo chmod +x /usr/local/bin/fan_speed_control

# Create service directory in /etc/s6/services
if [ ! -d "$SERVICE_DIR" ]; then
    sudo mkdir -p "$SERVICE_DIR"
fi

# Create run script directly in service directory
sudo tee "$SERVICE_DIR/run" > /dev/null <<'EOF'
#!/bin/sh
exec /usr/local/bin/fan_speed_control
EOF

# Make run script executable
sudo chmod +x "$SERVICE_DIR/run"

echo "Service installed at $SERVICE_DIR."

# Check if s6-svscan is already running
if pgrep -f "s6-svscan /etc/s6/services" > /dev/null; then
    echo "s6-svscan is already running. Service will be automatically picked up."
else
    echo "Starting s6-svscan..."
    sudo s6-svscan /etc/s6/services &
    echo "s6-svscan started."
fi