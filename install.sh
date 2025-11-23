#!/bin/sh

UDEV_RULE="/lib/udev/rules.d/71-lian-li-fans.rules"
VENDOR_ID="0cf2"
PRODUCT_ID="a102"

# Build the binary
echo "Building fan_speed_control..."
make
if [ $? -ne 0 ]; then
    echo "Build failed. Exiting."
    exit 1
fi

# Install binary to /usr/local/bin
echo "Installing binary to /usr/local/bin..."
sudo cp fan_speed_control /usr/local/bin/fan_speed_control
sudo chmod +x /usr/local/bin/fan_speed_control

# Create udev rule for HID device access
echo "Creating udev rule for Lian Li fan controller..."
echo "SUBSYSTEM==\"hidraw\", ATTRS{idVendor}==\"$VENDOR_ID\", ATTRS{idProduct}==\"$PRODUCT_ID\", MODE=\"0666\"" | sudo tee "$UDEV_RULE" > /dev/null

# Reload udev rules
echo "Reloading udev rules..."
sudo udevadm control --reload
sudo udevadm trigger

echo "Installation complete!"
echo "Binary installed to: /usr/local/bin/fan_speed_control"
echo "Udev rule created at: $UDEV_RULE"
echo ""
echo "To start the fan control automatically, add this to your startup:"
echo "  i3 config: exec --no-startup-id /usr/local/bin/fan_speed_control"
echo "  Fish config: /usr/local/bin/fan_speed_control &"