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
    echo "Usage: bash ./bin/test-dependencies-yml.sh <filename>"
    exit 1
fi

# Read the contents of the file
file_contents=$(cat "$filename")

# Enable case-insensitive matching
shopt -s nocasematch

# Regular expression pattern for version validation
version_pattern='^(v)?([0-9]+(\.[0-9]+)*(-[A-Za-z0-9]+)?|[A-Za-z0-9]+-[0-9]+(\.[0-9]+)*(-[A-Za-z0-9]+)?)$'

# Initialize a flag variable to track validation status
valid_versions=true

echo "Checking ${filename} for valid versions..."
# Parse the YAML file and validate the current_tag values
while IFS=: read -r key value; do
    # Remove leading/trailing whitespace from key and value
    key=$(echo "$key" | awk '{$1=$1};1')
    value=$(echo "$value" | awk '{$1=$1};1')

    # Skip lines that do not start with alphabetic characters
    if [[ ! $key =~ ^[A-Za-z] ]]; then
        continue
    fi

    # Output the dependency being checked
    echo -n "Validating version for $key... "
	echo "Found ${value}!..."

    # Check if the value matches the version pattern
    if [[ ! $value =~ $version_pattern ]]; then
        echo "Invalid version: $value"
        valid_versions=false
    else
        echo -e "OK"
    fi
done <<< "$file_contents"

# Exit with an error code if any version comparison is invalid
if ! "$valid_versions"; then
    echo -e "${red}One or more versions are invalid.${reset}"
    exit 1
else
    echo -e "${green}All checks passed!${reset} 🎉"
fi
