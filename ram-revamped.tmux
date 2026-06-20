#!/usr/bin/env bash
#
# ram-revamped.tmux: TPM entry point.
#
# Replaces the #{ram_*} placeholders in status-left and status-right with calls
# to the dispatcher, which reads cached values and never blocks the render.

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RAM_CMD="${PLUGIN_DIR}/src/ram.sh"

placeholders=(
  "\#{ram_percentage}"
  "\#{ram_icon}"
  "\#{ram_fg_color}"
  "\#{ram_bg_color}"
  "\#{ram_available}"
  "\#{ram_swap}"
  "\#{ram_breakdown}"
)

commands=(
  "#(${RAM_CMD} percentage)"
  "#(${RAM_CMD} icon)"
  "#(${RAM_CMD} fg_color)"
  "#(${RAM_CMD} bg_color)"
  "#(${RAM_CMD} available)"
  "#(${RAM_CMD} swap)"
  "#(${RAM_CMD} breakdown)"
)

interpolate() {
  local value="${1}"
  local i
  for (( i = 0; i < ${#placeholders[@]}; i++ )); do
    value="${value//${placeholders[i]}/${commands[i]}}"
  done
  echo "${value}"
}

update_option() {
  local option="${1}"
  local current
  current=$(tmux show-option -gqv "${option}")
  tmux set-option -gq "${option}" "$(interpolate "${current}")"
}

chmod +x "${RAM_CMD}" 2>/dev/null || true

update_option "status-left"
update_option "status-right"
