#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# Define some colors.
red="\e[31m"
green="\e[32m"
white="\e[97m"
reset="\e[0m"

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo -e "${white}Running tests for action-package-updater${reset}"
echo

# Initialize submodules if they haven't been initialized
if [[ ! -f "${SCRIPT_DIR}/libs/bats-core/bin/bats" ]]; then
    echo -e "${white}Initializing git submodules...${reset}"
    cd "${PROJECT_ROOT}"
    git submodule update --init --recursive
    echo
fi

# Check if bats is available
BATS_CMD="${SCRIPT_DIR}/libs/bats-core/bin/bats"

if [[ ! -x "${BATS_CMD}" ]]; then
    echo -e "${red}Bats not found at ${BATS_CMD}${reset}"
    echo "Please ensure git submodules are properly initialized."
    exit 1
fi

echo -e "${white}Running bats tests...${reset}"
cd "${PROJECT_ROOT}"

# Run the tests
if "${BATS_CMD}" test/*.bats; then
    echo
    echo -e "${green}All bats tests passed!${reset} 🎉"
else
    echo
    echo -e "${red}Some bats tests failed.${reset} ❌"
    exit 1
fi