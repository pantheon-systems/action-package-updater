# Tests

This directory contains the test suite for the action-package-updater.

## Test Framework

We use [Bats (Bash Automated Testing System)](https://github.com/bats-core/bats-core) for testing.

## Running Tests

To run all tests:

```bash
./test/run.sh
```

To run a specific test file:

```bash
./test/libs/bats-core/bin/bats test/version_handling.bats
```

To run a specific test:

```bash
./test/libs/bats-core/bin/bats test/version_handling.bats -f "extract_version_from_tag"
```

## Test Structure

- `test_helper.bash` - Common test setup and mocking utilities
- `version_handling.bats` - Tests for the new version handling functions
- `tika_integration.bats` - Integration tests specifically for the Apache Tika use case
- `gh` - Mock script for the GitHub CLI tool used in tests
- `run.sh` - Test runner script

## Dependencies

The tests use git submodules for the bats framework:

- `bats-core` - The main bats testing framework
- `bats-support` - Helper functions for tests
- `bats-assert` - Assertion helpers

These are automatically initialized when running `./test/run.sh`.

## Mock Setup

Tests use a mock `gh` script to simulate GitHub API responses without making real API calls. This ensures tests are fast and don't depend on external services.