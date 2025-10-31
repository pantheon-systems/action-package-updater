#!/usr/bin/env bats

load test_helper

@test "Apache Tika example: handles tag-based versioning correctly" {
    # This test demonstrates the fix for issue #35
    # Apache Tika has tags like: tika-1.3, 3.2.3, 3.2.2, 3.2.1, 3.0.0-BETA2, etc.
    # The function should return the latest stable version (3.2.3), not a beta or old prefixed version
    
    result=$(get_latest_version_from_tags "apache/tika")
    assert_equal "$result" "3.2.3"
}

@test "Version extraction handles tika prefix correctly" {
    result=$(extract_version_from_tag "tika-1.3")
    assert_equal "$result" "1.3"
}

@test "Version comparison correctly identifies 3.2.3 > 3.2.1" {
    # This represents the update from current version 3.2.1 to new version 3.2.3
    run version_gt "3.2.3" "3.2.1"
    assert_success
}

@test "Version comparison correctly identifies tika-1.3 (1.3) < 3.2.1" {
    # This ensures we don't regress to an older prefixed version
    run version_gt "1.3" "3.2.1"
    assert_failure
}