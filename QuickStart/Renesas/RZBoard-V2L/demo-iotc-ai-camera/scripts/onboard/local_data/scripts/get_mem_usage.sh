#!/bin/bash

# sourced from https://www.baeldung.com/linux/user-memory-usage

# Initialize the total memory usage variable
total_mem=0     

# Print column headers
printf "%-10s%-10s\n" User MemUsage'(%)'

# Loop through the sorted output of ps and calculate the memory usage per user
while read u m
do
    # Check if we're on a new user and print the total memory usage for the previous user
    [[ $old_user != $u ]] && { printf "%-10s%-0.1f\n" $old_user $total_mem; total_mem=0; }

    # Add the memory usage of the current process to the total memory usage
    total_mem="$(echo $m + $total_mem | bc)"    

    # Save the current user for the next iteration
    old_user=$u

# Read the output of ps, sort it by user, and loop through it
done < <(ps --no-headers -eo user,%mem| sort -k1)    

#EOF