This document outlines all custom commands built into this environment.

# The tp Command
A custom utility to quickly teleport between directories and manage workspace shortcuts.
```bash
tp [option]
```

## Available Options
| Option | Arguments | Description |
|---|---|---|
| [target_name] | None | Teleports directly to the specified target directory shortcut. |
| -a | [target_name] [target_path] | Adds a new shortcut mapping a target name to a specific directory path. |
| -d | [target_name] | Deletes an existing shortcut mapping. |
| -l | None | Lists all currently saved shortcut targets and their paths. |
> [!NOTE]
> The [target_name] is not case sensitive, any input will be formatted to all lower caps.

## Examples
```bash
# Add a new shortcut named 'docs' pointing to your Documents folder
tp -a docs ~/Documents

# List all your active shortcuts
tp -l

# Teleport to the 'docs' shortcut
tp docs

# Delete the 'docs' shortcut
tp -d docs
```