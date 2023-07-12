#!/bin/bash

set -eou pipefail

# Get the filename from the first positional argument
filename="$1"

# Check if the filename argument is provided
if [ -z "$filename" ]; then
    echo "No filename specified."
    echo "Usage: bash script.sh <filename>"
    exit 1
fi

# Read the contents of the file
file_contents=$(cat "$filename")

# Enable case-insensitive matching
shopt -s nocasematch

# Regular expression pattern for standard numeric format allowing RC or Beta releases
version_pattern='^([0-9]+\.){1,2}[0-9]+(-RC[0-9]+|-Beta[0-9]+)?$'

# Initialize a flag variable to track validation status
valid_versions=true

# Iterate over each line in the file
while IFS= read -r line; do
    # Check if the line matches the version pattern
    if [[ ! $line =~ $version_pattern ]]; then
        echo "Invalid version: $line"
        valid_versions=false
    fi
done <<< "$file_contents"

# Exit with an error code if any version comparison is invalid
if ! "$valid_versions"; then
    echo "One or more versions are invalid."
    exit 1
fi
