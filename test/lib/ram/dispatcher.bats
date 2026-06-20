#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  unset _RAM_REVAMPED_RAM_LOADED _RAM_REVAMPED_RENDER_LOADED
  export CACHE_SYNC=1
  source "${BATS_TEST_DIRNAME}/../../../src/ram.sh"
  read_ram_percentage() { echo "60"; }
}

teardown() {
  cleanup_test_environment
}

@test "ram.sh dispatcher - functions are defined" {
  function_exists main
  function_exists ram_refresh
  function_exists ram_tick
  function_exists ram_max_age
}

@test "ram.sh dispatcher - ram_max_age default is 5" {
  [[ "$(ram_max_age)" == "5" ]]
}

@test "ram.sh dispatcher - ram_max_age honors the interval option" {
  set_tmux_option "@ram_revamped_interval" "8"
  [[ "$(ram_max_age)" == "8" ]]
}

@test "ram.sh dispatcher - ram_refresh caches the percentage" {
  ram_refresh
  [[ "$(cache_get percent)" == "60" ]]
}

@test "ram.sh dispatcher - refresh subcommand caches the percentage" {
  main refresh
  [[ "$(cache_get percent)" == "60" ]]
}

@test "ram.sh dispatcher - percentage subcommand renders the cached value" {
  run main percentage
  [[ "${output}" == "60%" ]]
}

@test "ram.sh dispatcher - icon subcommand maps the cached value" {
  run main icon
  [[ "${output}" == "▰▰▱" ]]
}

@test "ram.sh dispatcher - unknown subcommand produces no output" {
  run main bogus
  [[ -z "${output}" ]]
}
