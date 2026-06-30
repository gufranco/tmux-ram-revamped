#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  unset _RAM_REVAMPED_HISTORY_LOADED
  source "${BATS_TEST_DIRNAME}/../../../src/lib/ram/history.sh"
}

teardown() {
  cleanup_test_environment
}

@test "history.sh - history_push appends to an empty buffer" {
  [[ "$(history_push "" 60 30)" == "60" ]]
}

@test "history.sh - history_push appends to a non-empty buffer" {
  [[ "$(history_push "10 20" 30 30)" == "10 20 30" ]]
}

@test "history.sh - history_push trims to the max size" {
  [[ "$(history_push "10 20 30" 40 2)" == "30 40" ]]
}

@test "history.sh - history_push falls back to a default size" {
  [[ "$(history_push "10" 20 bogus)" == "10 20" ]]
}

@test "history.sh - ram_history_push stores a numeric value" {
  ram_history_push 60
  [[ "$(get_tmux_option "@ram_revamped_history" "")" == "60" ]]
}

@test "history.sh - ram_history_push appends across calls" {
  ram_history_push 10
  ram_history_push 20
  [[ "$(get_tmux_option "@ram_revamped_history" "")" == "10 20" ]]
}

@test "history.sh - ram_history_push honors a custom size" {
  set_tmux_option "@ram_revamped_history_size" "2"
  ram_history_push 10
  ram_history_push 20
  ram_history_push 30
  [[ "$(get_tmux_option "@ram_revamped_history" "")" == "20 30" ]]
}

@test "history.sh - ram_history_push ignores a non-numeric value" {
  ram_history_push "x"
  [[ -z "$(get_tmux_option "@ram_revamped_history" "")" ]]
}
