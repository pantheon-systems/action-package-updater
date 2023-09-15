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
    echo "Usage: bash ./test-dependencies-yml.sh <filename>"
    exit 1
fi

# Enable case-insensitive matching
shopt -s nocasematch

# Regular expression patterns for validation
version_pattern='^(v)?([0-9]+(\.[0-9]+)*(-[A-Za-z0-9]+)?|[A-Za-z0-9]+-[0-9]+(\.[0-9]+)*(-[A-Za-z0-9]+)?|.+)$'
repo_pattern='^[^/]+/[^/]+$'
source_pattern='^(github|pecl)?$'

# Initialize a flag variable to track validation status
valid_schema=true
valid_versions=true
valid_repos=true
valid_sources=true

echo "Checking ${filename} for valid schema..."

echo -n "Checking dependencies.yml schema..."
# Validate the structure and values of dependencies.yml
if ! yq eval 'has("dependencies")' "$filename" >/dev/null 2>&1; then
    echo -e "${red}Invalid dependencies.yml schema: missing 'dependencies:' key.${reset}"
    valid_schema=false
fi
echo "OK"

# Perform further validation only if the schema is valid
if "$valid_schema"; then
    # Iterate over the dependencies and validate the current_tag and repo values
    while IFS=" " read -r key; do
        echo -n "Validating ${key}..."

        # Fetch and validate source, if it's empty assume 'github'
        source=$(yq eval ".dependencies.${key}.source" "$filename" 2>/dev/null)
        if [[ -z "$source" || "$source" == null ]]; then
            source="github"
            echo -ne "Checking source... Found null, assuming ${white}${source}${reset} "
        else
            echo -ne "Checking source... Found ${white}${source}${reset} "
        fi

        if [[ ! $source =~ $source_pattern ]]; then
            echo -e "${red}Invalid source for ${key}: ${source}${reset}"
            valid_sources=false
        else
            echo -ne "✅..."
        fi

        # Based on source, select appropriate repo pattern
        [[ "$source" == "pecl" ]] && repo_pattern='^[^/]+$' || repo_pattern='^[^/]+/[^/]+$'

		echo -n "Checking current_tag..."
        # Validate current_tag value
        current_tag=$(yq eval ".dependencies.${key}.current_tag" "$filename")
		echo -ne "${white}Found ${current_tag}${reset} "
        if [[ -z "$current_tag" || ! $current_tag =~ $version_pattern ]]; then
            echo -e "${red}Invalid version for ${key}: ${current_tag}${reset}"
            valid_versions=false
		else
			echo -ne "✅..."
        fi

		echo -n "Checking repo..."
        # Validate repo value
        repo=$(yq eval ".dependencies.${key}.repo" "$filename")
		echo -ne "Found ${white}${repo}${reset} "
        if [[ -z "$repo" || ! $repo =~ $repo_pattern ]]; then
            echo -e "${red}Invalid repo for ${key}: ${repo}${reset}"
            valid_repos=false
		else
			echo -e "✅"
        fi
    done <<< "$(yq eval '.dependencies | keys | .[]' "$filename")"
fi

# Print summary based on validation results
echo ""

if ! "$valid_sources"; then
    echo -e "${red}One or more dependencies have invalid sources.${reset}"
    exit 1
fi

if ! "$valid_schema"; then
    echo -e "${red}Invalid dependencies.yml schema: missing 'dependencies:' key.${reset}"
    exit 1
fi

if ! "$valid_versions" || ! "$valid_repos"; then
    echo -e "${red}One or more dependencies have invalid versions or repos.${reset}"
    exit 1
fi

echo -e "${green}All checks passed!${reset} 🎉"
