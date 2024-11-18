#!/bin/bash

# Define the directory path
directory="/var/log/ota/"

# Ensure the directory exists
if [ ! -d "$directory" ]; then
    >&2 echo "Directory does not exist: $directory"
    exit 1
fi

# Find the latest file
latest_file=$(ls -t $directory | head -1)

if [ -z "$latest_file" ]; then
    >&2 echo "No files found in the directory."
    exit 1
fi

# Define the start and end tags
start_tag="PAYLOADINSTALL START"
end_tag="PAYLOADINSTALL END"

# Initialize a flag to indicate whether we are inside the specified section
inside_section=0

echo "Files changed in OTA"
# Loop through the file and extract lines between the tags
while IFS= read -r line; do
    if [ "$line" = "$start_tag" ]; then
        inside_section=1
    elif [ "$line" = "$end_tag" ]; then
        inside_section=0
    elif [ $inside_section -eq 1 ]; then
        echo "$line"
    fi
done < "$directory$latest_file"
