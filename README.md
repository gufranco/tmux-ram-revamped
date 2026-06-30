<div align="center">

<h1>tmux-ram-revamped</h1>

**RAM usage for your tmux status bar, without ever blocking the status render.**

[![Tests](https://github.com/tmux-revamped/tmux-ram-revamped/actions/workflows/tests.yml/badge.svg)](https://github.com/tmux-revamped/tmux-ram-revamped/actions/workflows/tests.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE) [![Version](https://img.shields.io/badge/version-1.3.0-blue.svg)](CHANGELOG.md)

</div>

**17** placeholders · **2** platforms · **202** tests · **95%+** coverage

Shows RAM usage, available memory, swap, and a memory breakdown in your tmux status bar. The value is read from a tmux server user-option and returns instantly, while a detached worker recomputes it in the background. No temp files are used; all state lives in tmux options.

Inspired by the RAM metrics in [tmux-cpu](https://github.com/tmux-plugins/tmux-cpu). Built from [tmux-plugin-template](https://github.com/tmux-revamped/tmux-plugin-template).

<table>
<tr>
<td><b>Non-blocking</b><br>The status render reads a cached value and returns instantly. A detached worker recomputes in the background.</td>
<td><b>No temp files</b><br>All state lives in tmux server options. Nothing is written to disk.</td>
</tr>
<tr>
<td><b>Cross-platform</b><br>Runs on Linux and macOS, Intel and Apple Silicon, with built-in tools only.</td>
<td><b>Tested</b><br>112 tests with 95%+ coverage on every supported platform.</td>
</tr>
</table>

## Placeholders

| Placeholder | Output |
|-------------|--------|
| `#{ram_percentage}` | used memory, for example `61%` |
| `#{ram_icon}` | a tier icon for the current usage |
| `#{ram_fg_color}` | foreground color for the current tier |
| `#{ram_bg_color}` | background color for the current tier |
| `#{ram_available}` | available memory percent, for example `40%` |
| `#{ram_swap}` | swap used percent, empty when there is no swap |
| `#{ram_pressure}` | memory-pressure metric, for example `2%` |
| `#{ram_breakdown}` | memory composition, for example `W 3.2G C 1.1G I 2.0G F 4.5G` |
| `#{ram_swap_icon}` | warning icon shown while swap is in use |
| `#{ram_swap_color}` | warning color shown while swap is in use |
| `#{ram_absolute}` | absolute used over total, for example `12.3G / 32G` |
| `#{ram_commit}` | committed-memory ratio percent (Linux), early OOM warning |
| `#{ram_reclaimable}` | reclaimable cache size (Linux), for example `4.0G` |
| `#{ram_top_process}` | the largest memory consumer, for example `firefox 1.2G` |
| `#{ram_graph}` | history sparkline of recent usage, for example `▁▂▄▆█` |
| `#{ram_trend}` | trend arrow over the history window (`↑` `↓` `→`) |
| `#{ram_text}` | glyph-free plain-language line for screen readers |

## Install

With [TPM](https://github.com/tmux-plugins/tpm):

```tmux
set -g @plugin 'tmux-revamped/tmux-ram-revamped'
set -g status-right '#{ram_icon} #{ram_percentage}'
```

Press `prefix + I` to install.

## Detail popup

Press `prefix + M` to open a memory monitor in a tmux popup. It launches `btop`
or `htop` when present, otherwise `free` on Linux or `vm_stat` on macOS. On tmux
older than 3.2 it opens a window instead. Rebind it with `@ram_revamped_popup_key`.

## Configuration

| Option | Default | Meaning |
|--------|---------|---------|
| `@ram_revamped_interval` | `5` | seconds a sample stays fresh before a background re-sample |
| `@ram_revamped_percentage_format` | `%s%%` | printf format for the value |
| `@ram_revamped_medium_thresh` | `50` | usage percent at which the tier becomes medium |
| `@ram_revamped_high_thresh` | `85` | usage percent at which the tier becomes high |
| `@ram_revamped_low_icon` | `▰▱▱` | icon for the low tier |
| `@ram_revamped_medium_icon` | `▰▰▱` | icon for the medium tier |
| `@ram_revamped_high_icon` | `▰▰▰` | icon for the high tier |
| `@ram_revamped_low_fg_color` | empty | foreground for the low tier |
| `@ram_revamped_medium_fg_color` | empty | foreground for the medium tier |
| `@ram_revamped_high_fg_color` | empty | foreground for the high tier |
| `@ram_revamped_low_bg_color` | empty | background for the low tier |
| `@ram_revamped_medium_bg_color` | empty | background for the medium tier |
| `@ram_revamped_high_bg_color` | empty | background for the high tier |
| `@ram_revamped_available_format` | `%s%%` | format for available memory |
| `@ram_revamped_swap_format` | `%s%%` | format for swap usage |
| `@ram_revamped_pressure_format` | `%s%%` | format for the memory-pressure metric |
| `@ram_revamped_breakdown_format` | `W %sG C %sG I %sG F %sG` | format for the memory breakdown (four values: wired, compressed, inactive, free) |
| `@ram_revamped_absolute_format` | `%s / %s` | format for absolute used over total |
| `@ram_revamped_commit_format` | `%s%%` | format for the commit ratio |
| `@ram_revamped_reclaimable_format` | `%s` | format for the reclaimable cache figure |
| `@ram_revamped_top_process_format` | `%s %s` | format for the top memory process (name, size) |
| `@ram_revamped_history_size` | `30` | number of samples kept in the history ring |
| `@ram_revamped_trend_threshold` | `3` | percent change before the trend arrow flips |
| `@ram_revamped_trend_up` | `↑` | glyph for a rising trend |
| `@ram_revamped_trend_down` | `↓` | glyph for a falling trend |
| `@ram_revamped_trend_flat` | `→` | glyph for a steady trend |
| `@ram_revamped_swap_warn_thresh` | `1` | swap percent at or above which the warning shows |
| `@ram_revamped_swap_active_icon` | empty | icon shown by `#{ram_swap_icon}` while swap is active |
| `@ram_revamped_swap_active_color` | empty | color shown by `#{ram_swap_color}` while swap is active |
| `@ram_revamped_popup_key` | `M` | prefix key that opens the detail popup |
| `@ram_revamped_popup_width` | `80%` | popup width |
| `@ram_revamped_popup_height` | `60%` | popup height |
| `@ram_revamped_enable_logging` | `0` | set to `1` to log under `~/.tmux/ram-revamped-logs` |

## Theme color suggestions

The tier colors default to the 16 ANSI names, which the active theme remaps, so the plugin matches any theme out of the box; for exact hex copy one block below.

### Catppuccin Mocha

```tmux
set -g @ram_revamped_low_fg_color '#[fg=#a6e3a1]'
set -g @ram_revamped_medium_fg_color '#[fg=#f9e2af]'
set -g @ram_revamped_high_fg_color '#[fg=#f38ba8]'
```

### Dracula

```tmux
set -g @ram_revamped_low_fg_color '#[fg=#50fa7b]'
set -g @ram_revamped_medium_fg_color '#[fg=#f1fa8c]'
set -g @ram_revamped_high_fg_color '#[fg=#ff5555]'
```

### Nord

```tmux
set -g @ram_revamped_low_fg_color '#[fg=#a3be8c]'
set -g @ram_revamped_medium_fg_color '#[fg=#ebcb8b]'
set -g @ram_revamped_high_fg_color '#[fg=#bf616a]'
```

### Gruvbox Dark

```tmux
set -g @ram_revamped_low_fg_color '#[fg=#b8bb26]'
set -g @ram_revamped_medium_fg_color '#[fg=#fabd2f]'
set -g @ram_revamped_high_fg_color '#[fg=#fb4934]'
```

### Tokyo Night

```tmux
set -g @ram_revamped_low_fg_color '#[fg=#9ece6a]'
set -g @ram_revamped_medium_fg_color '#[fg=#e0af68]'
set -g @ram_revamped_high_fg_color '#[fg=#f7768e]'
```

### Solarized Dark

```tmux
set -g @ram_revamped_low_fg_color '#[fg=#859900]'
set -g @ram_revamped_medium_fg_color '#[fg=#b58900]'
set -g @ram_revamped_high_fg_color '#[fg=#dc322f]'
```

The `#{ram_breakdown}` placeholder reports the memory composition: wired,
compressed, inactive, and free in gigabytes. On macOS these come from `vm_stat`
and match Activity Monitor; on Linux they map to buffers, zero, cached, and free.

The `#{ram_pressure}` placeholder reports a memory-pressure metric. On Linux it
is the `some avg10` value from `/proc/pressure/memory`, the percent of time
memory was stalled in the last ten seconds. On macOS it is the free percent
reported by the native `memory_pressure` tool. The placeholder is empty when the
source is unavailable.

## Support by platform and architecture

Works on every supported platform and architecture with built-in tools, no extra
package required.

| Platform | Source |
|----------|--------|
| macOS (Intel and Apple Silicon) | `vm_stat` page counts |
| Linux (x86_64 and arm64) | `/proc/meminfo`, used is total minus available |

## Development

```sh
make test
make lint
make coverage
```

## License

[MIT](LICENSE), copyright Gustavo Franco.
