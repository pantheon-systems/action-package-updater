#!/usr/bin/env bats

load test_helper

@test "extract_version_from_tag: basic version" {
    result=$(extract_version_from_tag "3.2.1")
    assert_equal "$result" "3.2.1"
}

# c/f issue #35, PR #36
@test "extract_version_from_tag: version with v prefix" {
    result=$(extract_version_from_tag "v3.2.1")
    assert_equal "$result" "3.2.1"
}

@test "extract_version_from_tag: prefixed tag" {
    result=$(extract_version_from_tag "tika-3.2.1")
    assert_equal "$result" "3.2.1"
}

@test "extract_version_from_tag: complex prefix" {
    result=$(extract_version_from_tag "apache-tika-3.2.1")
    assert_equal "$result" "3.2.1"
}

@test "extract_version_from_tag: underscore separator" {
    result=$(extract_version_from_tag "project_v3.2.1")
    assert_equal "$result" "3.2.1"
}

@test "extract_version_from_tag: two-part version" {
    result=$(extract_version_from_tag "3.2")
    assert_equal "$result" "3.2"
}

@test "extract_version_from_tag: four-part version" {
    result=$(extract_version_from_tag "3.2.1.4")
    assert_equal "$result" "3.2.1.4"
}

@test "extract_version_from_tag: invalid tag returns empty" {
    result=$(extract_version_from_tag "not-a-version")
    assert_equal "$result" ""
}

@test "extract_version_from_tag: empty tag returns empty" {
    result=$(extract_version_from_tag "")
    assert_equal "$result" ""
}

@test "extract_version_from_tag: only letters returns empty" {
    result=$(extract_version_from_tag "abcd")
    assert_equal "$result" ""
}

@test "version_gt: 3.2.2 > 3.2.1" {
    run version_gt "3.2.2" "3.2.1"
    assert_success
}

@test "version_gt: 3.2.1 not > 3.2.2" {
    run version_gt "3.2.1" "3.2.2"
    assert_failure
}

@test "version_gt: 3.2.1 not > 3.2.1 (equal)" {
    run version_gt "3.2.1" "3.2.1"
    assert_failure
}

@test "version_gt: 3.3.0 > 3.2.9" {
    run version_gt "3.3.0" "3.2.9"
    assert_success
}

@test "version_gt: 4.0.0 > 3.9.9" {
    run version_gt "4.0.0" "3.9.9"
    assert_success
}

@test "version_gt: 3.2 not > 3.2.1" {
    run version_gt "3.2" "3.2.1"
    assert_failure
}

@test "version_gt: 3.2.1 > 3.2" {
    run version_gt "3.2.1" "3.2"
    assert_success
}

@test "version_gt: 10.1.0 > 9.99.99" {
    run version_gt "10.1.0" "9.99.99"
    assert_success
}


@test "get_latest_version_from_tags: apache/tika returns latest stable" {
    result=$(get_latest_version_from_tags "apache/tika")
    assert_equal "$result" "3.2.3"
}

@test "get_latest_version_from_tags: test/project skips RC versions" {
    result=$(get_latest_version_from_tags "test/project")
    assert_equal "$result" "v2.0.5"
}

@test "get_latest_version_from_tags: project/with-betas skips alpha and beta" {
    result=$(get_latest_version_from_tags "project/with-betas")
    assert_equal "$result" "1.4.2"
}

@test "get_latest_version_from_tags: empty repo returns empty" {
    result=$(get_latest_version_from_tags "empty/repo")
    assert_equal "$result" ""
}