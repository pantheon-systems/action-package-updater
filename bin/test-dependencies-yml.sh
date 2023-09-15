#!/bin/bash

set -eou pipefail

# Define some colors.
red="\e[31m"
green="\e[32m"
white="\e[97m"
reset="\e[0m"

# Get the filename from the first positional argument
filename="$1"

# Check if the filename argument is provided
if [ -z "$filename" ]; then
    echo "No filename specified."
    echo "Usage: bash ./bin/test-dependencies-yml.sh <filename>"
    exit 1
fi

# Enable case-insensitive matching
shopt -s nocasematch

# Regular expression pattern for version validation
version_pattern='^(v)?([0-9]+(\.[0-9]+)*(-[A-Za-z0-9]+)?|[A-Za-z0-9]+-[0-9]+(\.[0-9]+)*(-[A-Za-z0-9]+)?|.+)$'

# Initialize a flag variable to track validation status
valid_versions=true

echo "Checking ${filename} for valid versions..."

# Iterate over the dependencies and validate the current_tag values
for key in $(yq eval '.dependencies | keys | .[]' "$filename"); do
    # Output the dependency being checked
    echo -n "Validating version for ${key}..."

    # Get the current_tag value using yq
    current_tag=$(yq eval ".dependencies.${key}.current_tag" "$filename")
    echo -n "${white}Found ${current_tag}${reset}..."

    # Check if the value matches the version pattern
    if [[ ! $current_tag =~ $version_pattern ]]; then
        echo -e "${red}Invalid version: ${current_tag}${reset}"
        valid_versions=false
    else
        echo -e "${green}OK${reset}"
    fi
done

# Exit with an error code if any version is invalid
if ! "$valid_versions"; then
    echo -e "${red}One or more versions are invalid.${reset}"
    exit 1
else
    echo -e "${green}All checks passed!${reset} 🎉"
fi
