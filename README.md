# tmux-ram-revamped

RAM usage for your tmux status bar, without ever blocking the status render.

The value is read from a tmux server user-option and returns instantly, while a
detached worker recomputes it in the background. No temp files are used; all state
lives in tmux options.

Inspired by the RAM metrics in
[tmux-cpu](https://github.com/tmux-plugins/tmux-cpu). Built from
[tmux-plugin-template](https://github.com/gufranco/tmux-plugin-template).

## Placeholders

| Placeholder | Output |
|-------------|--------|
| `#{ram_percentage}` | used memory, for example `61%` |
| `#{ram_icon}` | a tier icon for the current usage |
| `#{ram_fg_color}` | foreground color for the current tier |
| `#{ram_bg_color}` | background color for the current tier |

## Install

With [TPM](https://github.com/tmux-plugins/tpm):

```tmux
set -g @plugin 'gufranco/tmux-ram-revamped'
set -g status-right '#{ram_icon} #{ram_percentage}'
```

Press `prefix + I` to install.

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
| `@ram_revamped_enable_logging` | `0` | set to `1` to log under `~/.tmux/ram-revamped-logs` |

## Platform support

| Platform | Source |
|----------|--------|
| macOS | `vm_stat` page counts |
| Linux | `/proc/meminfo`, used = total minus available |

## License

[MIT](LICENSE), copyright Gustavo Franco.
