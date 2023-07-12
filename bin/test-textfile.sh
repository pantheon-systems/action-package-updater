#!/bin/bash

set -eou pipefail

# Define some colors.
red="\e[31m"
green="\e[32m"
reset="\e[0m"

# Get the filename from the first positional argument
filename="$1"

# Check if the filename argument is provided
if [ -z "$filename" ]; then
    echo "No filename specified."
    echo "Usage: bash script.sh <filename>"
    exit 1
fi

# Read the contents of the file, filtering version assignments
file_contents=$(grep -E '^[[:space:]]*declare -r [A-Z_]+_DEFAULT_VERSION=[0-9.]+(-[A-Za-z0-9]+)?$' "$filename")

# Enable case-insensitive matching
shopt -s nocasematch

# Regular expression pattern for version validation
version_pattern='^[0-9]+(\.[0-9]+)*(-[A-Za-z0-9]+)?$'

# Initialize a flag variable to track validation status
valid_versions=true

echo "Checking ${filename} for valid versions..."

# Iterate over each line in the file
while IFS= read -r line; do
    # Extract the variable name and version from the line
    name=$(echo "$line" | awk -F "=" '{print $1}' | awk '{print $NF}')
    version=$(echo "$line" | awk -F "=" '{print $2}')

    # Format the extension name
    formatted_name=${name%"_DEFAULT_VERSION"}
    formatted_name=$(tr '[:upper:]' '[:lower:]' <<< "$formatted_name")

    # Output the extension name being checked
    echo "Validating version for $formatted_name..."
	echo "Found $version!"

    # Check if the version matches the pattern
    if [[ ! $version =~ $version_pattern ]]; then
        echo "Invalid version: $version"
        valid_versions=false
    fi
done <<< "$file_contents"

# Exit with an error code if any version comparison is invalid
if ! "$valid_versions"; then
    echo "${red}One or more versions are invalid.${reset}"
    exit 1
fi

echo "${green}All checks passed!${reset} 🎉"