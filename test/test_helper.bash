#!/usr/bin/env bash

# Load bats libraries
load 'libs/bats-support/load'
load 'libs/bats-assert/load'

# Set up test environment
setup() {
    # Get the containing directory of this file
    DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"
    # Make our mock gh script and executables in bin/ visible to PATH
    PATH="$DIR:$DIR/../bin:$PATH"
    
    # Set required environment variables for testing
    export DEPENDENCIES_YML="${DIR}/../fixtures/dependencies.yml"
    export OUTPUT_FILE="${DIR}/../fixtures/PHP_EXTENSION_VERSIONS"
    export DRY_RUN="true"
    export DEFAULT_BRANCH="main"
    export THIS_REPO="test/repo"
    export ACTIVE_BRANCH="test-branch"
    
    # Source the main script to get access to functions
    source "$DIR/../bin/dependency-check-pr.sh"
}

