# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**SteelWool** is a macOS command-line tool that removes Chrome user data on shared lab accounts. It solves the problem where students on shared user accounts remain logged into their Google accounts after use.

The tool reads a curated list of file paths (`targets.txt`) and deletes them to return Chrome to its initial state. This is only necessary for Chrome; Firefox and Safari can be configured to auto-clear data on exit.

## Architecture

The project is organized into three shell scripts:

### `libsteelwool.sh` (Library)
Shared utilities sourced by other scripts. Contains:
- **Flag functions**: `logging()`, `verbose()`, `dry()` — test if flags are enabled
- **Directory management**: `assure_directories()` — creates/validates macOS standard directories:
  - `~/Library/Logs/SteelWool/` (logs)
  - `~/Library/Application Support/SteelWool/` (data, config, targets.txt)
- **Logging functions**: `logstd()`, `logwarn()`, `logerr()` — handle both stdout and file logging with timestamps

### `steelwool.sh` (Main)
The primary executable. Workflow:
1. Validate it's not running as root (security requirement)
2. Source `libsteelwool.sh` with defensive fallback (checks installed path first, then local directory)
3. Ensure required directories exist
4. Parse CLI flags (`-v`/`--verbose`, `-n`/`--dry-run`, `-V`/`--version`)
5. Verify `targets.txt` exists; error if missing
6. Read `targets.txt` line-by-line and delete each file/directory with `rm -rf`
7. Log results (successful removals, errors, skipped non-existent paths)

Key safety feature: accepts `--dry-run` to preview deletions without executing.

### `steelwooldiff.sh` (Generator)
Generates and maintains `targets.txt`. Not fully implemented yet, but intended to:
- Generate snapshots of Chrome before login (`chromebefore.txt`) and after login (`chromeafter.txt`)
- Use `diff` to identify what files Chrome created/modified
- Produce `targets.txt` from the diff
- Can be re-run after Chrome updates to regenerate targets

## Key Design Decisions

- **zsh shell** — scripts use zsh syntax (`#!/bin/zsh`)
- **No root execution** — intentional security constraint; prevents accidental removal of system files
- **Defensive sourcing** — `steelwool.sh` tries two paths for `libsteelwool.sh`:
  1. System location: `/usr/local/share/SteelWool/libsteelwool.sh` (after installation)
  2. Local fallback: `$(dirname "$0")/libsteelwool.sh` (development)
- **macOS standard directories** — uses `~/Library/Logs` and `~/Library/Application Support` per Apple conventions
- **Centralized targets.txt** — allows secure updates without shipping new code; currently manual updates until security model is stronger
- **Verbose and dry-run modes** — both can be enabled together for safe testing

## Common Development Tasks

### Test removal without executing
```sh
./steelwool.sh --dry-run --verbose
```

### Run with verbose output
```sh
./steelwool.sh --verbose
```

### Check version
```sh
./steelwool.sh --version
```

### View logs
```sh
tail -f ~/Library/Logs/SteelWool/steelwool.log
```

## Installation Structure

After installation via brew or manual setup:
- Main scripts: `/usr/local/bin/steelwool`, `/usr/local/bin/steelwooldiff`
- Library: `/usr/local/share/SteelWool/libsteelwool.sh`
- User data: `~/Library/Application Support/SteelWool/targets.txt`

## Important Notes for Contributors

- **targets.txt is sensitive** — it contains paths that will be deleted. Currently only the maintainer should modify it due to security considerations (no current validation mechanism).
- **Test thoroughly** — use `--dry-run` before any actual deletion
- **Maintain zsh compatibility** — do not use bash-only features
- **Log all operations** — use logging functions rather than direct echo for consistency
- **Preserve defensive sourcing** — when modifying imports, maintain fallback logic in case libsteelwool is in non-standard locations
