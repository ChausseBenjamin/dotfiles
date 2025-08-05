# Smart Enter Plugin

A yazi plugin that provides intelligent navigation and file opening behavior.

## Behavior

- **For directories (including symlinked directories)**: Enters/navigates into the directory
- **For files**: Opens the file with the configured application (same as pressing 'o')

## Installation

Place this plugin in your `~/.config/yazi/plugins/smart-enter.yazi/` directory.

## Usage

Bind it in your `keymap.toml`:

```toml
{ on = "<Enter>", run = "plugin smart-enter", desc = "Enter directory or open file" },
{ on = "l", run = "plugin smart-enter", desc = "Enter directory or open file" },
```
