---
title: MamboDot Command Reference
description: Regenerate MamboDot colour artifacts and use its Zsh directory-bookmark helper.
order: 20
---

::page{layout="docs" width="normal" sidebar=true}

# MamboDot Command Reference

## Colour update

`script/mambodot.sh` is MamboDot's repository-local adapter for MamboColour. It is not installed as a global command.

```bash
./script/mambodot.sh update
```

The command requires `mbcolor` on `PATH` and makes exactly 12 calls into a temporary staging directory:

| Consumer | Formats per theme | Themes | Calls |
|---|---|---:|---:|
| `dot/hypr/.config/hypr/themes/` | `hyprlua`, `hyprlang` | 4 | 8 |
| `dot/waybar/.config/waybar/` | `waybar` | 4 | 4 |

The four themes are `mamboorchelight`, `mamboorchedark`, `mambooutbacklight`, and `mambooutbackdark`. All 12 staged files must exist and be non-empty before the wrapper replaces tracked outputs, and symlinked targets are refused. A provider failure therefore leaves the committed model untouched. `script/install.sh` delegates colour generation to this command; it does not compile MamboFont or run font-cache commands.

The current tracked model was refreshed and reviewed with MamboColour commit `66f0c26d6d6462c54c023a4842e49dc6fa0b3c1c`.

Run the provider check after changing either script:

```bash
./script/test.sh
```

The check stubs `mbcolor` with copies of the current tracked model, verifies the exact staged calls, checks usage failures, and guards the installer boundary. It is not currently run by CI.

## `tp`

`tp` is a Zsh function for jumping to directories and maintaining named bookmarks. It is defined by the managed Zsh configuration, so it is available after that configuration is linked and loaded.

```bash
tp <name-or-path>
tp -a <name> <path>
tp -d <name>
tp -l
```

| Form | Result |
|---|---|
| `tp <name>` | Change to the bookmarked directory |
| `tp <path>` | Change directly to an existing directory |
| `tp -a <name> <path>` | Add or replace a bookmark using the absolute target path |
| `tp -d <name>` | Remove a bookmark |
| `tp -l` | List saved bookmarks |
| `tp` | Show built-in help |

Bookmark names are stored in lowercase and matched case-insensitively.

## Examples

```bash
tp -a docs ~/Documents
tp -l
tp docs
tp -d docs
```

## Storage

Bookmarks live in `.config/zsh/tp_bookmarks.txt` beside the managed `.zshrc`. Both the Stow ignore rules and Git ignore rules exclude that machine-local file.

A bookmark record uses a whitespace-separated name and path. Paths containing spaces are therefore not represented safely by the current format.
