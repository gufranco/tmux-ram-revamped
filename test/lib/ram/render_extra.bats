#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  unset _RAM_REVAMPED_RENDER_LOADED
  source "${BATS_TEST_DIRNAME}/../../../src/lib/ram/render.sh"
}

teardown() {
  cleanup_test_environment
}

@test "render.sh - _ram_kb_human scales to K, M and G" {
  [[ "$(_ram_kb_human 512)" == "512K" ]]
  [[ "$(_ram_kb_human 2048)" == "2M" ]]
  [[ "$(_ram_kb_human 1572864)" == "1.5G" ]]
  [[ "$(_ram_kb_human 33554432)" == "32G" ]]
}

@test "render.sh - ram_render_absolute is empty on cold start" {
  [[ -z "$(ram_render_absolute "")" ]]
}

@test "render.sh - ram_render_absolute is empty when total is zero" {
  [[ -z "$(ram_render_absolute "0 0")" ]]
}

@test "render.sh - ram_render_absolute formats used over total" {
  [[ "$(ram_render_absolute "8388608 33554432")" == "8G / 32G" ]]
}

@test "render.sh - ram_render_absolute honors a custom format" {
  set_tmux_option "@ram_revamped_absolute_format" "%s of %s"
  [[ "$(ram_render_absolute "8388608 33554432")" == "8G of 32G" ]]
}

@test "render.sh - ram_render_commit formats with default and custom" {
  [[ -z "$(ram_render_commit "")" ]]
  [[ "$(ram_render_commit 42)" == "42%" ]]
  set_tmux_option "@ram_revamped_commit_format" "commit %s%%"
  [[ "$(ram_render_commit 42)" == "commit 42%" ]]
}

@test "render.sh - ram_render_reclaimable formats with default and custom" {
  [[ -z "$(ram_render_reclaimable "")" ]]
  [[ "$(ram_render_reclaimable 4194304)" == "4G" ]]
  set_tmux_option "@ram_revamped_reclaimable_format" "cache %s"
  [[ "$(ram_render_reclaimable 4194304)" == "cache 4G" ]]
}

@test "render.sh - ram_render_top_process formats name and size" {
  [[ -z "$(ram_render_top_process "")" ]]
  [[ "$(ram_render_top_process "firefox 1258291")" == "firefox 1.2G" ]]
}

@test "render.sh - ram_render_top_process keeps multi-word names" {
  [[ "$(ram_render_top_process "Google Chrome 2097152")" == "Google Chrome 2G" ]]
}

@test "render.sh - ram_render_top_process honors a custom format" {
  set_tmux_option "@ram_revamped_top_process_format" "%s (%s)"
  [[ "$(ram_render_top_process "vim 2048")" == "vim (2M)" ]]
}

@test "render.sh - ram_render_graph is empty on cold start" {
  [[ -z "$(ram_render_graph "")" ]]
}

@test "render.sh - ram_render_graph is empty with no numeric samples" {
  [[ -z "$(ram_render_graph "x y z")" ]]
}

@test "render.sh - ram_render_graph maps samples to block glyphs" {
  run ram_render_graph "0 50 100"
  [[ -n "${output}" ]]
  [[ "${output}" == "▁▅█" ]]
}

@test "render.sh - ram_render_trend is empty on cold start" {
  [[ -z "$(ram_render_trend "")" ]]
}

@test "render.sh - ram_render_trend is empty with no numeric samples" {
  [[ -z "$(ram_render_trend "a b")" ]]
}

@test "render.sh - ram_render_trend reports rising, falling and flat" {
  [[ "$(ram_render_trend "10 20 90")" == "↑" ]]
  [[ "$(ram_render_trend "90 50 10")" == "↓" ]]
  [[ "$(ram_render_trend "50 50 51")" == "→" ]]
}

@test "render.sh - ram_render_trend honors custom glyphs" {
  set_tmux_option "@ram_revamped_trend_up" "UP"
  [[ "$(ram_render_trend "10 90")" == "UP" ]]
}

@test "render.sh - ram_render_text is empty without a percent" {
  [[ -z "$(ram_render_text "" "" "")" ]]
}

@test "render.sh - ram_render_text composes the plain-language line" {
  [[ "$(ram_render_text 60 40 25)" == "RAM 60% used, 40% available, swap 25%" ]]
}

@test "render.sh - ram_render_text omits empty available and swap" {
  [[ "$(ram_render_text 60 "" "")" == "RAM 60% used" ]]
}

@test "render.sh - _ram_swap_active honors the warn threshold" {
  _ram_swap_active 5
  run _ram_swap_active 0
  [[ "${status}" -ne 0 ]]
  set_tmux_option "@ram_revamped_swap_warn_thresh" "10"
  run _ram_swap_active 5
  [[ "${status}" -ne 0 ]]
}

@test "render.sh - _ram_swap_active treats non-numeric as zero" {
  run _ram_swap_active "abc"
  [[ "${status}" -ne 0 ]]
}

@test "render.sh - ram_render_swap_icon is empty on cold start" {
  [[ -z "$(ram_render_swap_icon "")" ]]
}

@test "render.sh - ram_render_swap_icon shows the icon only when active" {
  set_tmux_option "@ram_revamped_swap_active_icon" "!"
  [[ "$(ram_render_swap_icon 5)" == "!" ]]
  [[ -z "$(ram_render_swap_icon 0)" ]]
}

@test "render.sh - ram_render_swap_color is empty on cold start" {
  [[ -z "$(ram_render_swap_color "")" ]]
}

@test "render.sh - ram_render_swap_color shows the color only when active" {
  set_tmux_option "@ram_revamped_swap_active_color" "#[fg=red]"
  [[ "$(ram_render_swap_color 5)" == "#[fg=red]" ]]
  [[ -z "$(ram_render_swap_color 0)" ]]
}
