#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  unset _RAM_REVAMPED_RAM_LOADED _RAM_REVAMPED_RENDER_LOADED
  export CACHE_SYNC=1
  source "${BATS_TEST_DIRNAME}/../../../src/ram.sh"
  read_ram_percentage() { echo "60"; }
  read_available() { echo "40"; }
  read_swap() { echo "25"; }
  read_pressure() { echo "12"; }
  read_breakdown() { echo "2048 1024 3072 4096"; }
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

@test "ram.sh dispatcher - ram_refresh caches every metric" {
  ram_refresh
  [[ "$(cache_get percent)" == "60" ]]
  [[ "$(cache_get available)" == "40" ]]
  [[ "$(cache_get swap)" == "25" ]]
  [[ "$(cache_get pressure)" == "12" ]]
}

@test "ram.sh dispatcher - available and swap subcommands render the cache" {
  run main available
  [[ "${output}" == "40%" ]]
  run main swap
  [[ "${output}" == "25%" ]]
}

@test "ram.sh dispatcher - pressure subcommand renders the cache" {
  run main pressure
  [[ "${output}" == "12%" ]]
}

@test "ram.sh dispatcher - breakdown subcommand renders the cache" {
  run main breakdown
  [[ "${output}" == "W 2.0G C 1.0G I 3.0G F 4.0G" ]]
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
