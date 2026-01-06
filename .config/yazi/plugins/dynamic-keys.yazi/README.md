# Dynamic Keys Plugin

I have an awk script that generates shortcuts for the various apps I use.
This lets me maintain a single list instead of micro-managing every app.

Inspired by that script, I built this plugin to import a list of shortcuts from
an easy to generate lua table and configures a bunch of shortcuts using it.

### Navigation

1. Press `g` to activate the navigation shortcut system
2. Select from available shortcuts with descriptive names
3. Continue typing to narrow down options
4. Navigate automatically when a match is found

### File Operations

1. Select files in Yazi first
2. Press `Y` to copy files or `M` to move files to a shortcut destination
3. Select the destination shortcut (same progressive matching as navigation)
4. Confirm the operation when prompted
5. Files will be copied/moved to the destination

## Configuration

The plugin reads shortcuts from `~/.cache/shortcuts.lua` which should contain a
table with entries like:

```lua
return {
    { name = "CV", dir = "/path/to/cv", keys = "cv" },
    { name = "Config", dir = "/path/to/config", keys = "cf" },
    { name = "Downloads", dir = "/home/user/Downloads", keys = "dl" },
    { name = "Pictures", dir = "/home/user/Pictures", keys = "pic" },
    -- ...
}
```

## Key Bindings

Add these to your `keymap.toml`:

```toml
[[mgr.prepend_keymap]]
on = "g"
run = "plugin dynamic-keys --args=navigate"
desc = "Navigate to shortcut"

[[mgr.prepend_keymap]]
on = "Y"
run = "plugin dynamic-keys --args=copy"
desc = "Copy to shortcut"

[[mgr.prepend_keymap]]
on = "M"
run = "plugin dynamic-keys --args=move"
desc = "Move to shortcut"
```
