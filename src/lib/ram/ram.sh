#!/usr/bin/env bash
#
# ram.sh: RAM usage acquisition.
#
# Pure parsers turn command output into a used-memory percentage. Reader
# functions wrap the host probes behind thin seams so tests can stub them.

[[ -n "${_RAM_REVAMPED_RAM_LOADED:-}" ]] && return 0
_RAM_REVAMPED_RAM_LOADED=1

_RAM_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${_RAM_LIB_DIR}/../utils/platform.sh"
# shellcheck source=/dev/null
source "${_RAM_LIB_DIR}/../utils/has-command.sh"

# _meminfo_field TEXT KEY -> the kB value for a /proc/meminfo key.
_meminfo_field() {
  printf '%s\n' "${1}" | awk -v k="${2}:" '$1 == k { print $2; exit }'
}

# ram_pct_from_meminfo TEXT -> integer used-memory percent from /proc/meminfo.
ram_pct_from_meminfo() {
  local total avail
  total=$(_meminfo_field "${1}" "MemTotal")
  avail=$(_meminfo_field "${1}" "MemAvailable")
  [[ "${total}" =~ ^[0-9]+$ && "${avail}" =~ ^[0-9]+$ && "${total}" -gt 0 ]] \
    || { echo 0; return 0; }
  awk -v t="${total}" -v a="${avail}" 'BEGIN { printf "%.0f", ((t - a) / t) * 100 }'
}

# _vmstat_pages TEXT LABEL -> the page count for a vm_stat label.
_vmstat_pages() {
  printf '%s\n' "${1}" | grep -i "${2}" | grep -oE '[0-9]+' | head -1
}

# ram_pct_from_vmstat TEXT -> integer used-memory percent from vm_stat.
ram_pct_from_vmstat() {
  local free active inactive spec wired compressed
  free=$(_vmstat_pages "${1}" "Pages free")
  active=$(_vmstat_pages "${1}" "Pages active")
  inactive=$(_vmstat_pages "${1}" "Pages inactive")
  spec=$(_vmstat_pages "${1}" "Pages speculative")
  wired=$(_vmstat_pages "${1}" "Pages wired down")
  compressed=$(_vmstat_pages "${1}" "occupied by compressor")
  free=${free:-0}; active=${active:-0}; inactive=${inactive:-0}
  spec=${spec:-0}; wired=${wired:-0}; compressed=${compressed:-0}
  local used=$(( active + wired + compressed ))
  local total=$(( free + active + inactive + spec + wired + compressed ))
  (( total <= 0 )) && { echo 0; return 0; }
  awk -v u="${used}" -v t="${total}" 'BEGIN { printf "%.0f", (u / t) * 100 }'
}

# Host-probe seams. Tests override these.
_read_meminfo() { cat /proc/meminfo 2>/dev/null; }
_read_vmstat() { vm_stat 2>/dev/null; }

# read_ram_percentage -> used-memory percent for the host.
read_ram_percentage() {
  if is_linux; then
    ram_pct_from_meminfo "$(_read_meminfo)"
  elif is_macos && has_command vm_stat; then
    ram_pct_from_vmstat "$(_read_vmstat)"
  else
    echo 0
  fi
}

export -f _meminfo_field
export -f ram_pct_from_meminfo
export -f _vmstat_pages
export -f ram_pct_from_vmstat
export -f _read_meminfo
export -f _read_vmstat
export -f read_ram_percentage
