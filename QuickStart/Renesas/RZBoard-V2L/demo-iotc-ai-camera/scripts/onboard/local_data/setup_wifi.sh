#!/bin/bash

WIFI_CONF="/etc/wpa_supplicant.conf"

# Function to scan for available Wi-Fi networks
scan_wifi() {
    echo "Scanning for available Wi-Fi networks..."
    ifconfig mlan0 up
    iwlist mlan0 scan | grep SSID
}

# Function to add new Wi-Fi credentials
add_wifi_credentials() {
    local ssid="$1"
    local psk="$2"

    # Check if the SSID is already in the configuration
    if grep -q "ssid=\"$ssid\"" "$WIFI_CONF"; then
        echo "Wi-Fi SSID \"$ssid\" is already configured. Skipping addition."
    else
        echo "Adding new Wi-Fi credentials for SSID \"$ssid\"..."
        wpa_passphrase "$ssid" "$psk" | sudo tee -a "$WIFI_CONF" > /dev/null
        echo "Wi-Fi credentials for SSID \"$ssid\" have been added."
    fi
}

# Function to connect to Wi-Fi
connect_wifi() {
    echo "Starting Wi-Fi connection..."
    ifconfig mlan0 up
    wpa_supplicant -B -i mlan0 -c "$WIFI_CONF"
    udhcpc -i mlan0 -n -R
}

# Function to check if Wi-Fi is already configured
check_wifi_configured() {
    if [ -f "$WIFI_CONF" ] && grep -q "network={" "$WIFI_CONF"; then
        echo "Wi-Fi is already configured."
        return 0
    else
        echo "No Wi-Fi configuration found."
        return 1
    fi
}

# Main script logic
echo "Checking Wi-Fi configuration..."
if check_wifi_configured; then
    echo "Would you like to:"
    echo "1. Overwrite existing Wi-Fi configuration"
    echo "2. Add a new Wi-Fi network"
    echo "3. Cancel"
    read -p "Enter your choice (1, 2, or 3): " CHOICE

    if [ "$CHOICE" -eq 1 ]; then
        echo "Overwriting existing Wi-Fi configuration..."
        echo -n "" | sudo tee "$WIFI_CONF" > /dev/null
    elif [ "$CHOICE" -eq 2 ]; then
        echo "Adding a new Wi-Fi network..."
    else
        echo "Exiting."
        exit 0
    fi
fi

# Scan for available networks
scan_wifi

# Prompt for new Wi-Fi credentials
read -p "Enter the Wi-Fi SSID: " SSID
read -sp "Enter the Wi-Fi password: " PSK
echo

# Add the Wi-Fi credentials
add_wifi_credentials "$SSID" "$PSK"

# Connect to Wi-Fi
connect_wifi

# Confirm the setup
echo "Wi-Fi setup is complete. Use the following command to check the connection status:"
echo "    ifconfig mlan0"

