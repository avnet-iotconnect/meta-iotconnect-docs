#!/bin/bash

# Define paths for each LED
led_blue="/sys/class/leds/led_blue/brightness"
led_red="/sys/class/leds/led_red/brightness"
led_green="/sys/class/leds/led_green/brightness"

# Function to set LED states
set_leds() {
    echo "$1" > "$led_red"
    echo "$2" > "$led_green"
    echo "$3" > "$led_blue"
}

# Check if the user provided an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <color>"
    echo "Available colors: red, green, blue, yellow, cyan, magenta, white, off"
    exit 1
fi

# Get the color from the command line argument
color="$1"

# Control LEDs based on the provided color
case "$color" in
    red)
        set_leds 1 0 0  # Red ON, Green OFF, Blue OFF
        echo "Red color activated."
        ;;
    green)
        set_leds 0 1 0  # Red OFF, Green ON, Blue OFF
        echo "Green color activated."
        ;;
    blue)
        set_leds 0 0 1  # Red OFF, Green OFF, Blue ON
        echo "Blue color activated."
        ;;
    yellow)
        set_leds 1 1 0  # Red ON, Green ON, Blue OFF (Yellow)
        echo "Yellow color activated."
        ;;
    cyan)
        set_leds 0 1 1  # Red OFF, Green ON, Blue ON (Cyan)
        echo "Cyan color activated."
        ;;
    magenta)
        set_leds 1 0 1  # Red ON, Green OFF, Blue ON (Magenta)
        echo "Magenta color activated."
        ;;
    white)
        set_leds 1 1 1  # Red ON, Green ON, Blue ON (White)
        echo "White color activated."
        ;;
    off)
        set_leds 0 0 0  # Turn off all LEDs
        echo "All LEDs turned off."
        ;;
    *)
        echo "Invalid color: $color"
        echo "Available colors: red, green, blue, yellow, cyan, magenta, white, off"
        exit 1
        ;;
esac


