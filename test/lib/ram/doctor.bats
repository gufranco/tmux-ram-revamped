#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  unset _RAM_REVAMPED_DOCTOR_LOADED
  source "${BATS_TEST_DIRNAME}/../../../src/lib/ram/doctor.sh"
}

teardown() {
  cleanup_test_environment
}

@test "doctor.sh - _doctor_probe reports a found command" {
  has_command() { return 0; }
  [[ "$(_doctor_probe "swap" "vm_stat")" == "swap: vm_stat found" ]]
}

@test "doctor.sh - _doctor_probe reports a missing command" {
  has_command() { return 1; }
  [[ "$(_doctor_probe "swap" "vm_stat")" == "swap: vm_stat missing" ]]
}

@test "doctor.sh - ram_doctor reports the Linux source" {
  _PLATFORM_OS_CACHE="Linux"
  has_command() { return 0; }
  run ram_doctor
  [[ "${output}" == *"tmux-ram-revamped doctor"* ]]
  [[ "${output}" == *"platform: Linux"* ]]
  [[ "${output}" == *"/proc/meminfo (Linux)"* ]]
  [[ "${output}" == *"swap: vm_stat found"* ]]
}

@test "doctor.sh - ram_doctor reports the macOS source" {
  _PLATFORM_OS_CACHE="Darwin"
  has_command() { return 1; }
  run ram_doctor
  [[ "${output}" == *"platform: Darwin"* ]]
  [[ "${output}" == *"vm_stat (macOS)"* ]]
  [[ "${output}" == *"popup monitor: btop missing"* ]]
}

@test "doctor.sh - ram_doctor reports an unsupported platform" {
  _PLATFORM_OS_CACHE="Plan9"
  has_command() { return 1; }
  run ram_doctor
  [[ "${output}" == *"unsupported platform"* ]]
}
