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

@test "render.sh - _ram_level classifies by thresholds" {
  [[ "$(_ram_level 10 50 85)" == "low" ]]
  [[ "$(_ram_level 60 50 85)" == "medium" ]]
  [[ "$(_ram_level 90 50 85)" == "high" ]]
}

@test "render.sh - _ram_level treats non-numeric as zero" {
  [[ "$(_ram_level xx 50 85)" == "low" ]]
}

@test "render.sh - ram_render_percentage is empty on cold start" {
  [[ -z "$(ram_render_percentage "")" ]]
}

@test "render.sh - ram_render_percentage uses the default format" {
  [[ "$(ram_render_percentage 73)" == "73%" ]]
}

@test "render.sh - ram_render_percentage honors a custom format" {
  set_tmux_option "@ram_revamped_percentage_format" "RAM %s%%"
  [[ "$(ram_render_percentage 73)" == "RAM 73%" ]]
}

@test "render.sh - ram_render_icon is empty on cold start" {
  [[ -z "$(ram_render_icon "")" ]]
}

@test "render.sh - ram_render_icon maps levels with default thresholds" {
  [[ "$(ram_render_icon 90)" == "▰▰▰" ]]
  [[ "$(ram_render_icon 60)" == "▰▰▱" ]]
  [[ "$(ram_render_icon 10)" == "▰▱▱" ]]
}

@test "render.sh - ram_render_icon honors a custom icon" {
  set_tmux_option "@ram_revamped_high_icon" "FULL"
  [[ "$(ram_render_icon 95)" == "FULL" ]]
}

@test "render.sh - ram_render_fg is empty by default" {
  [[ -z "$(ram_render_fg 95)" ]]
}

@test "render.sh - ram_render_fg returns the configured color" {
  set_tmux_option "@ram_revamped_high_fg_color" "#[fg=red]"
  [[ "$(ram_render_fg 95)" == "#[fg=red]" ]]
}

@test "render.sh - ram_render_bg returns the configured color" {
  set_tmux_option "@ram_revamped_low_bg_color" "#[bg=green]"
  [[ "$(ram_render_bg 10)" == "#[bg=green]" ]]
}

@test "render.sh - ram_render_bg is empty on cold start" {
  [[ -z "$(ram_render_bg "")" ]]
}

@test "render.sh - ram_render_swap formats with default and custom" {
  [[ -z "$(ram_render_swap "")" ]]
  [[ "$(ram_render_swap 25)" == "25%" ]]
  set_tmux_option "@ram_revamped_swap_format" "swap %s%%"
  [[ "$(ram_render_swap 25)" == "swap 25%" ]]
}

@test "render.sh - ram_render_available formats with default and custom" {
  [[ -z "$(ram_render_available "")" ]]
  [[ "$(ram_render_available 40)" == "40%" ]]
  set_tmux_option "@ram_revamped_available_format" "free %s%%"
  [[ "$(ram_render_available 40)" == "free 40%" ]]
}
