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

@test "ram.sh - _meminfo_field reads a key" {
  local txt=$'MemTotal:       16000 kB\nMemAvailable:    4000 kB'
  [[ "$(_meminfo_field "${txt}" MemTotal)" == "16000" ]]
  [[ "$(_meminfo_field "${txt}" MemAvailable)" == "4000" ]]
}

@test "ram.sh - ram_pct_from_meminfo computes used percent" {
  local txt=$'MemTotal:       1000 kB\nMemAvailable:    250 kB'
  [[ "$(ram_pct_from_meminfo "${txt}")" == "75" ]]
}

@test "ram.sh - ram_pct_from_meminfo is 0 with missing fields" {
  [[ "$(ram_pct_from_meminfo "")" == "0" ]]
}

@test "ram.sh - _vmstat_pages reads a label" {
  local txt=$'Pages free:    100.\nPages active:  300.'
  [[ "$(_vmstat_pages "${txt}" "Pages free")" == "100" ]]
}

@test "ram.sh - ram_pct_from_vmstat computes used percent" {
  local txt=$'Pages free:                  100.\nPages active:                300.\nPages inactive:              100.\nPages speculative:             0.\nPages wired down:            100.\nPages occupied by compressor:  0.'
  [[ "$(ram_pct_from_vmstat "${txt}")" == "67" ]]
}

@test "ram.sh - ram_pct_from_vmstat is 0 with no pages" {
  [[ "$(ram_pct_from_vmstat "")" == "0" ]]
}

@test "ram.sh - read_ram_percentage reads meminfo on Linux" {
  _PLATFORM_OS_CACHE="Linux"
  _read_meminfo() { printf 'MemTotal:  1000 kB\nMemAvailable: 250 kB\n'; }
  [[ "$(read_ram_percentage)" == "75" ]]
}

@test "ram.sh - read_ram_percentage reads vm_stat on macOS" {
  _PLATFORM_OS_CACHE="Darwin"
  has_command() { return 0; }
  _read_vmstat() {
    printf 'Pages free: 100.\nPages active: 300.\nPages inactive: 100.\nPages speculative: 0.\nPages wired down: 100.\nPages occupied by compressor: 0.\n'
  }
  [[ "$(read_ram_percentage)" == "67" ]]
}

@test "ram.sh - read_ram_percentage is 0 on macOS without vm_stat" {
  _PLATFORM_OS_CACHE="Darwin"
  has_command() { return 1; }
  [[ "$(read_ram_percentage)" == "0" ]]
}

@test "ram.sh - read_ram_percentage is 0 on an unknown platform" {
  _PLATFORM_OS_CACHE="Plan9"
  [[ "$(read_ram_percentage)" == "0" ]]
}

@test "ram.sh - avail_from_meminfo computes available percent" {
  local txt=$'MemTotal: 1000 kB\nMemAvailable: 250 kB'
  [[ "$(avail_from_meminfo "${txt}")" == "25" ]]
  [[ "$(avail_from_meminfo "")" == "0" ]]
}

@test "ram.sh - avail_from_vmstat computes available percent" {
  local txt=$'Pages free: 100.\nPages active: 300.\nPages inactive: 100.\nPages speculative: 0.\nPages wired down: 100.\nPages occupied by compressor: 0.'
  [[ "$(avail_from_vmstat "${txt}")" == "33" ]]
  [[ "$(avail_from_vmstat "")" == "0" ]]
}

@test "ram.sh - swap_from_meminfo computes used and total" {
  local txt=$'SwapTotal: 2048 kB\nSwapFree: 512 kB'
  [[ "$(swap_from_meminfo "${txt}")" == "1536 2048" ]]
}

@test "ram.sh - swap_from_sysctl parses vm.swapusage" {
  [[ "$(swap_from_sysctl 'vm.swapusage: total = 2048.00M  used = 512.00M  free = 1536.00M')" == "524288 2097152" ]]
}

@test "ram.sh - swap_pct computes percent and handles empty swap" {
  [[ "$(swap_pct 512 2048)" == "25" ]]
  [[ -z "$(swap_pct 0 0)" ]]
}

@test "ram.sh - read_available uses meminfo on Linux" {
  _PLATFORM_OS_CACHE="Linux"
  _read_meminfo() { printf 'MemTotal: 1000 kB\nMemAvailable: 400 kB\n'; }
  [[ "$(read_available)" == "40" ]]
}

@test "ram.sh - read_available uses vm_stat on macOS" {
  _PLATFORM_OS_CACHE="Darwin"
  has_command() { return 0; }
  _read_vmstat() { printf 'Pages free: 100.\nPages active: 300.\nPages inactive: 100.\nPages speculative: 0.\nPages wired down: 100.\nPages occupied by compressor: 0.\n'; }
  [[ "$(read_available)" == "33" ]]
}

@test "ram.sh - read_available is 0 on an unknown platform" {
  _PLATFORM_OS_CACHE="Plan9"
  [[ "$(read_available)" == "0" ]]
}

@test "ram.sh - read_swap reads meminfo on Linux" {
  _PLATFORM_OS_CACHE="Linux"
  _read_meminfo() { printf 'SwapTotal: 2048 kB\nSwapFree: 1024 kB\n'; }
  [[ "$(read_swap)" == "50" ]]
}

@test "ram.sh - read_swap reads sysctl on macOS" {
  _PLATFORM_OS_CACHE="Darwin"
  _read_swapusage() { echo 'vm.swapusage: total = 2048.00M  used = 1024.00M  free = 1024.00M'; }
  [[ "$(read_swap)" == "50" ]]
}

@test "ram.sh - read_swap is empty without swap" {
  _PLATFORM_OS_CACHE="Linux"
  _read_meminfo() { printf 'SwapTotal: 0 kB\nSwapFree: 0 kB\n'; }
  [[ -z "$(read_swap)" ]]
}

@test "ram.sh - host-probe seams are callable" {
  run _read_meminfo
  run _read_vmstat
  run _read_swapusage
  true
}
