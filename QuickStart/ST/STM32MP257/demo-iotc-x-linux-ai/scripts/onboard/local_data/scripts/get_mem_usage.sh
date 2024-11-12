#!/bin/bash

# Directory to save memory usage files
OUTPUT_DIR="/usr/iotc/local/data"

# Ensure the output directory exists
mkdir -p "$OUTPUT_DIR"

# Initialize the total memory usage variables
declare -A mem_usage_per_user  # Associative array to store memory usage by user
total_mem=0.0  # Variable to track total memory usage across all users

# Loop through the output of ps, get user and memory usage, and add to the total for each user
while read -r user mem; do
    # Accumulate memory usage per user
    mem_usage_per_user["$user"]=$(echo "${mem_usage_per_user[$user]:-0} + $mem" | bc)
    # Accumulate total memory usage
    total_mem=$(echo "$total_mem + $mem" | bc)
done < <(ps --no-headers -eo user,%mem)

# Write total memory usage to a file
echo "$total_mem" > "$OUTPUT_DIR/total_mem"

# Write specific user memory usage to files, or 0 if the user has no processes
echo "${mem_usage_per_user[root]:-0}" > "$OUTPUT_DIR/root_mem"
echo "${mem_usage_per_user[systemd+]:-0}" > "$OUTPUT_DIR/systemd_mem"
echo "${mem_usage_per_user[weston]:-0}" > "$OUTPUT_DIR/weston_mem"

# Optionally, print output for confirmation
echo "Total memory usage: $total_mem%"
echo "Root memory usage: ${mem_usage_per_user[root]:-0}%"
echo "Systemd memory usage: ${mem_usage_per_user[systemd+]:-0}%"
echo "Weston memory usage: ${mem_usage_per_user[weston]:-0}%"
