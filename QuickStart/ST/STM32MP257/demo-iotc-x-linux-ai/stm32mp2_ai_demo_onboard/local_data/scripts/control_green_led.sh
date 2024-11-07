#!/bin/bash

# Define the GPIO chip and line for the green LED
gpiochip="gpiochip0"
gpioline="14"  # Corresponds to PA14 (green LED)

# Check if the user provided an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <0 or 1>"
    exit 1
fi

# Get the value from the command line argument (0 or 1)
value="$1"

# Check if the provided value is either 0 (turn on) or 1 (turn off)
if [ "$value" -ne 0 ] && [ "$value" -ne 1 ]; then
    echo "Error: Input must be either 0 (on) or 1 (off)."
    exit 1
fi

# Use gpioset to control the green LED (PA14)
gpioset -c "$gpiochip" "$gpioline"="$value"

# Check if the command was successful
if [ $? -eq 0 ]; then
    echo "Green LED set to '$value' (0 = on, 1 = off) on GPIO PA14 successfully."
else
    echo "Error setting GPIO PA14."
    exit 1
fi

