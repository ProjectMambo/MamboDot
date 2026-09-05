---
title: MamboDot Command Reference
description: Use the Zsh directory-bookmark helper shipped with MamboDot.
order: 20
---

::page{layout="docs" width="normal" sidebar=true}

# MamboDot Command Reference

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
