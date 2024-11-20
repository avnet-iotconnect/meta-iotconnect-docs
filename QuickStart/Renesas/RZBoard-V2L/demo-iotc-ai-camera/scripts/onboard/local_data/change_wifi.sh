#!/bin/bash

echo "Changing Wi-Fi credentials..."
read -p "Enter the Wi-Fi SSID to connect to: " SSID
read -sp "Enter the Wi-Fi password: " SSID_PASSWD
echo

# Backup the existing wpa_supplicant.conf
cp /etc/wpa_supplicant.conf /etc/wpa_supplicant.conf.bak

# Configure new credentials
wpa_passphrase "$SSID" "$SSID_PASSWD" >> /etc/wpa_supplicant.conf

# Restart Wi-Fi connection
echo "Restarting Wi-Fi connection..."
wpa_supplicant -B -i mlan0 -c /etc/wpa_supplicant.conf
udhcpc -i mlan0 -n -R

echo "Wi-Fi credentials updated and connection restarted."

