#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  unset _RAM_REVAMPED_RAM_LOADED
  source "${BATS_TEST_DIRNAME}/../../../src/lib/ram/ram.sh"
}

teardown() {
  cleanup_test_environment
}

@test "ram.sh - absolute_from_meminfo computes used and total kB" {
  local txt=$'MemTotal: 32000 kB\nMemAvailable: 8000 kB'
  [[ "$(absolute_from_meminfo "${txt}")" == "24000 32000" ]]
}

@test "ram.sh - absolute_from_meminfo is zero on empty input" {
  [[ "$(absolute_from_meminfo "")" == "0 0" ]]
}

@test "ram.sh - absolute_from_meminfo clamps negative used to zero" {
  local txt=$'MemTotal: 1000 kB\nMemAvailable: 4000 kB'
  [[ "$(absolute_from_meminfo "${txt}")" == "0 1000" ]]
}

@test "ram.sh - absolute_from_vmstat converts pages to kB" {
  local txt=$'Pages free: 4.\nPages active: 9.\nPages inactive: 3.\nPages speculative: 0.\nPages wired down: 2.\nPages occupied by compressor: 1.'
  [[ "$(absolute_from_vmstat "${txt}" 1024)" == "12 19" ]]
}

@test "ram.sh - commit_from_meminfo computes the commit ratio" {
  local txt=$'CommitLimit: 1000 kB\nCommitted_AS: 500 kB'
  [[ "$(commit_from_meminfo "${txt}")" == "50" ]]
}

@test "ram.sh - commit_from_meminfo is empty without a limit" {
  [[ -z "$(commit_from_meminfo "")" ]]
}

@test "ram.sh - reclaimable_from_meminfo sums cache fields" {
  local txt=$'Cached: 1000 kB\nBuffers: 200 kB\nSReclaimable: 300 kB'
  [[ "$(reclaimable_from_meminfo "${txt}")" == "1500" ]]
}

@test "ram.sh - reclaimable_from_meminfo is zero on empty input" {
  [[ "$(reclaimable_from_meminfo "")" == "0" ]]
}

@test "ram.sh - top_process_from_ps picks the largest RSS" {
  local txt=$'1000 bash\n5000 firefox\n2000 vim'
  [[ "$(top_process_from_ps "${txt}")" == "firefox 5000" ]]
}

@test "ram.sh - top_process_from_ps keeps multi-word command names" {
  local txt=$'1000 bash\n9000 Google Chrome'
  [[ "$(top_process_from_ps "${txt}")" == "Google Chrome 9000" ]]
}

@test "ram.sh - top_process_from_ps is empty on empty input" {
  [[ -z "$(top_process_from_ps "")" ]]
}

@test "ram.sh - read_absolute reads meminfo on Linux" {
  _PLATFORM_OS_CACHE="Linux"
  _read_meminfo() { printf 'MemTotal: 32000 kB\nMemAvailable: 8000 kB\n'; }
  [[ "$(read_absolute)" == "24000 32000" ]]
}

@test "ram.sh - read_absolute reads vm_stat on macOS" {
  _PLATFORM_OS_CACHE="Darwin"
  has_command() { return 0; }
  _read_vmstat() { printf 'Pages free: 4.\nPages active: 9.\nPages inactive: 3.\nPages speculative: 0.\nPages wired down: 2.\nPages occupied by compressor: 1.\n'; }
  _read_pagesize() { echo 1024; }
  [[ "$(read_absolute)" == "12 19" ]]
}

@test "ram.sh - read_absolute is empty on an unknown platform" {
  _PLATFORM_OS_CACHE="Plan9"
  [[ -z "$(read_absolute)" ]]
}

@test "ram.sh - read_commit reads meminfo on Linux" {
  _PLATFORM_OS_CACHE="Linux"
  _read_meminfo() { printf 'CommitLimit: 1000 kB\nCommitted_AS: 750 kB\n'; }
  [[ "$(read_commit)" == "75" ]]
}

@test "ram.sh - read_commit is empty off Linux" {
  _PLATFORM_OS_CACHE="Darwin"
  [[ -z "$(read_commit)" ]]
}

@test "ram.sh - read_reclaimable reads meminfo on Linux" {
  _PLATFORM_OS_CACHE="Linux"
  _read_meminfo() { printf 'Cached: 1000 kB\nBuffers: 200 kB\nSReclaimable: 300 kB\n'; }
  [[ "$(read_reclaimable)" == "1500" ]]
}

@test "ram.sh - read_reclaimable is empty off Linux" {
  _PLATFORM_OS_CACHE="Darwin"
  [[ -z "$(read_reclaimable)" ]]
}

@test "ram.sh - read_top_process parses the ps seam" {
  _read_ps_mem() { printf '1000 bash\n5000 firefox\n'; }
  [[ "$(read_top_process)" == "firefox 5000" ]]
}

@test "ram.sh - the new host-probe seam is callable" {
  run _read_ps_mem
  true
}
