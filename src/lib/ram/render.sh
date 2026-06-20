#!/usr/bin/env bash
#
# render.sh: map cached RAM values to icons, colors, and formatted text.

[[ -n "${_RAM_REVAMPED_RENDER_LOADED:-}" ]] && return 0
_RAM_REVAMPED_RENDER_LOADED=1

_RAM_RENDER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${_RAM_RENDER_DIR}/../tmux/tmux-ops.sh"

# _ram_level VALUE MEDIUM HIGH -> low|medium|high by integer thresholds.
_ram_level() {
  local v="${1%%.*}" med="${2}" high="${3}"
  [[ "${v}" =~ ^-?[0-9]+$ ]] || v=0
  if (( v >= high )); then
    echo "high"
  elif (( v >= med )); then
    echo "medium"
  else
    echo "low"
  fi
}

_ram_value_level() {
  _ram_level "${1:-0}" "$(get_tmux_option "@ram_revamped_medium_thresh" "50")" \
    "$(get_tmux_option "@ram_revamped_high_thresh" "85")"
}

ram_render_percentage() {
  local raw="${1}"
  [[ -z "${raw}" ]] && { echo ""; return 0; }
  local fmt
  fmt=$(get_tmux_option "@ram_revamped_percentage_format" "%s%%")
  # shellcheck disable=SC2059
  printf "${fmt}" "${raw}"
}

ram_render_icon() {
  [[ -z "${1}" ]] && { echo ""; return 0; }
  case "$(_ram_value_level "${1}")" in
    high)   get_tmux_option "@ram_revamped_high_icon" "▰▰▰" ;;
    medium) get_tmux_option "@ram_revamped_medium_icon" "▰▰▱" ;;
    *)      get_tmux_option "@ram_revamped_low_icon" "▰▱▱" ;;
  esac
}

ram_render_fg() {
  [[ -z "${1}" ]] && { echo ""; return 0; }
  get_tmux_option "@ram_revamped_$(_ram_value_level "${1}")_fg_color" ""
}

ram_render_bg() {
  [[ -z "${1}" ]] && { echo ""; return 0; }
  get_tmux_option "@ram_revamped_$(_ram_value_level "${1}")_bg_color" ""
}

ram_render_swap() {
  [[ -z "${1}" ]] && { echo ""; return 0; }
  local fmt
  fmt=$(get_tmux_option "@ram_revamped_swap_format" "%s%%")
  # shellcheck disable=SC2059
  printf "${fmt}" "${1}"
}

ram_render_available() {
  [[ -z "${1}" ]] && { echo ""; return 0; }
  local fmt
  fmt=$(get_tmux_option "@ram_revamped_available_format" "%s%%")
  # shellcheck disable=SC2059
  printf "${fmt}" "${1}"
}

export -f _ram_level
export -f _ram_value_level
export -f ram_render_percentage
export -f ram_render_icon
export -f ram_render_fg
export -f ram_render_bg
export -f ram_render_swap
export -f ram_render_available
