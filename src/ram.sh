#!/usr/bin/env bash
#
# ram.sh: command dispatcher for tmux-ram-revamped.
#
# Usage:
#   ram.sh percentage | icon | fg_color | bg_color
#   ram.sh refresh

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

export CACHE_PREFIX="ram_revamped"
export PLUGIN_LOG_NS="ram-revamped"

# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/utils/has-command.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/utils/platform.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/tmux/tmux-ops.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/utils/cache.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/ram/ram.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/ram/render.sh"

ram_max_age() {
  get_tmux_option "@ram_revamped_interval" "5"
}

ram_refresh() {
  cache_set percent "$(read_ram_percentage)"
  cache_set available "$(read_available)"
  cache_set swap "$(read_swap)"
}

ram_tick() {
  cache_refresh_if_stale percent "$(ram_max_age)" ram_refresh
}

main() {
  local cmd="${1:-}"

  if [[ "${cmd}" == "refresh" ]]; then
    ram_refresh
    return 0
  fi

  ram_tick

  case "${cmd}" in
    percentage) ram_render_percentage "$(cache_get percent)" ;;
    icon)       ram_render_icon "$(cache_get percent)" ;;
    fg_color)   ram_render_fg "$(cache_get percent)" ;;
    bg_color)   ram_render_bg "$(cache_get percent)" ;;
    available)  ram_render_available "$(cache_get available)" ;;
    swap)       ram_render_swap "$(cache_get swap)" ;;
    *)          return 0 ;;
  esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
