# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-06-20

### Added

- Available-memory placeholder `#{ram_available}` and swap-usage placeholder
  `#{ram_swap}`.
- macOS swap via `sysctl vm.swapusage`, Linux swap via `/proc/meminfo`.

## [1.0.0] - 2026-06-19

### Added

- RAM usage placeholders: `#{ram_percentage}`, `#{ram_icon}`,
  `#{ram_fg_color}`, `#{ram_bg_color}`.
- Non-blocking design: usage is computed in a background worker and read from a
  tmux user-option, with no temp files.
- macOS usage from `vm_stat`, Linux usage from `/proc/meminfo`.
- Configurable thresholds, icons, colors, and format string.
