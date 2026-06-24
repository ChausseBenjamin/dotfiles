local shortcuts_cache = {}
local shortcuts_loaded = false
local plugin_config = {}

local function expand_path(path)
	if path:match("^~/") then
		return os.getenv("HOME") .. "/" .. path:sub(3)
	end
	return path
end

local function setup(opts)
	plugin_config = opts or {}
	-- Reset cache to reload with new config
	shortcuts_loaded = false
	shortcuts_cache = {}
end

local function read_yazi_config()
	-- Try to read yazi.toml directly
	local yazi_config_path = os.getenv("HOME") .. "/.config/yazi/yazi.toml"
	local file = io.open(yazi_config_path, "r")
	if not file then
		return nil
	end

	local content = file:read("*all")
	file:close()

	-- Simple TOML parsing for our specific use case
	local config = {}
	local in_quicknav = false
	local current_entry = {}

	for line in content:gmatch("[^\r\n]+") do
		local line = line:gsub("^%s+", ""):gsub("%s+$", "")

		-- Skip comments and empty lines
		if line:match("^#") or line == "" then
			goto continue
		end

		if line == "[quicknav]" then
			in_quicknav = true
		elseif line:match("^%[") then
			in_quicknav = false
		elseif in_quicknav and line:match("^%[%[quicknav%.shortcuts%]%]") then
			-- This is an array entry marker, continue
		elseif in_quicknav and (line:match("^keys") or line:match("^dir") or line:match("^name")) then
			-- Parse array entry fields
			local keys = line:match('^keys%s*=%s*"([^"]*)"')
			local dir = line:match('^dir%s*=%s*"([^"]*)"')
			local name = line:match('^name%s*=%s*"([^"]*)"')

			if keys then
				current_entry.keys = keys
			elseif dir then
				current_entry.dir = dir
			elseif name then
				current_entry.name = name
			end

			-- If we have all required fields, add to config
			if current_entry.keys and current_entry.dir then
				config.shortcuts = config.shortcuts or {}
				table.insert(config.shortcuts, {
					keys = current_entry.keys,
					dir = current_entry.dir,
					name = current_entry.name or current_entry.dir
				})
				current_entry = {}
			end
		end

		::continue::
	end

	return config
end

local function load_shortcuts()
	if shortcuts_loaded then
		return shortcuts_cache
	end

	-- Try to load from setup configuration first
	local config = plugin_config

	-- If no setup config, try to read from yazi.toml
	if not config or not config.shortcuts then
		config = read_yazi_config()
	end
	if config then
		-- Check if shortcuts are defined inline in yazi.toml
		if config.shortcuts and type(config.shortcuts) == "table" then
			shortcuts_cache = {}
			for _, shortcut in ipairs(config.shortcuts) do
				if shortcut.keys and shortcut.dir then
					shortcuts_cache[shortcut.keys] = {
						dir = expand_path(shortcut.dir),
						name = shortcut.name or shortcut.dir
					}
				end
			end
			shortcuts_loaded = true
			return shortcuts_cache
		end

		-- Check if an external shortcuts file is specified
		if config.shortcuts_file then
			local shortcuts_file = expand_path(config.shortcuts_file)
			local file = io.open(shortcuts_file, "r")
			if file then
				local content = file:read("*all")
				file:close()

				-- Try to parse as TOML first if it's a .toml file
				if shortcuts_file:match("%.toml$") then
					-- For TOML files, we'd need a TOML parser
					-- For now, we'll fall back to treating it as Lua
					ya.notify({
						title = "Warning",
						content = "TOML parsing not yet implemented, falling back to Lua",
						timeout = 2.0
					})
				end

				-- Parse as Lua file
				local func, err = load(content)
				if func then
					local shortcuts = func()
					if shortcuts and type(shortcuts) == "table" then
						shortcuts_cache = {}
						for _, shortcut in ipairs(shortcuts) do
							if shortcut.keys and shortcut.dir then
								shortcuts_cache[shortcut.keys] = {
									dir = expand_path(shortcut.dir),
									name = shortcut.name or shortcut.dir
								}
							end
						end
						shortcuts_loaded = true
						return shortcuts_cache
					end
				else
					ya.notify({
						title = "Error",
						content = "Error parsing shortcuts file: " .. tostring(err),
						timeout = 3.0
					})
				end
			else
				ya.notify({
					title = "Error",
					content = "Cannot open shortcuts file: " .. shortcuts_file,
					timeout = 3.0
				})
			end
		end
	end

	-- Fallback to default locations: XDG_CACHE_HOME then HOME/.cache
	local potential_paths = {}
	local xdg_cache_home = os.getenv("XDG_CACHE_HOME")
	if xdg_cache_home then
		table.insert(potential_paths, xdg_cache_home .. "/shortcuts.lua")
	end
	table.insert(potential_paths, os.getenv("HOME") .. "/.cache/shortcuts.lua")

	for _, shortcuts_file in ipairs(potential_paths) do
		local file = io.open(shortcuts_file, "r")
		if file then
			local content = file:read("*all")
			file:close()

			local func, err = load(content)
			if func then
				local shortcuts = func()
				if shortcuts and type(shortcuts) == "table" then
					shortcuts_cache = {}
					for _, shortcut in ipairs(shortcuts) do
						if shortcut.keys and shortcut.dir then
							shortcuts_cache[shortcut.keys] = {
								dir = expand_path(shortcut.dir),
								name = shortcut.name or shortcut.dir
							}
						end
					end
					shortcuts_loaded = true
					return shortcuts_cache
				end
			else
				ya.notify({
					title = "Error",
					content = "Error parsing shortcuts.lua: " .. tostring(err),
					timeout = 3.0
				})
			end
		end
	end

	-- If no shortcuts found, return empty table but don't show error
	ya.notify({
		title = "Info",
		content = "No shortcuts file found. Add shortcuts to yazi.toml [quicknav] section or create shortcuts.lua",
		timeout = 2.0
	})

	shortcuts_cache = {}
	shortcuts_loaded = true
	return shortcuts_cache
end

local function handle_static_shortcuts(first_key)
	-- Handle static exceptions that should not use dynamic shortcuts

	if first_key == "h" then
		-- gh -> cd ~ (go to home directory)
		local home_dir = os.getenv("HOME") or "~"
		ya.emit("cd", { Url(home_dir) })
		return true
	elseif first_key == "g" then
		-- gg -> go to top of the list
		ya.emit("arrow", { "top" })
		return true
	end

	return false
end

local function capture_keys(action_verb)
	local shortcuts = load_shortcuts()
	if not next(shortcuts) then
		return nil
	end

	local input = ""
	local max_attempts = 4

	for i = 1, max_attempts do
		-- Build candidates dynamically based on current input
		local cands = {}
		local potential_matches = {}

		for shortcut_key, shortcut_data in pairs(shortcuts) do
			if shortcut_key:sub(1, #input) == input then
				potential_matches[shortcut_key] = shortcut_data
			end
		end

		-- Add static shortcuts to candidates if they match the input
		if input == "" then
			-- Add static shortcuts to the initial candidates
			table.insert(cands, { on = "h", desc = "Go to home directory (~)" })
			table.insert(cands, { on = "g", desc = "Go to top of list" })
		end

		-- If no potential matches and no static shortcuts, we're done
		if not next(potential_matches) and input ~= "" then
			ya.notify({
				title = "No shortcut",
				content = "No shortcut matches: " .. input,
				timeout = 2.0
			})
			return nil
		end

		-- If only one match and it's exact, return it
		if potential_matches[input] then
			return potential_matches[input]
		end

		-- Build candidates for the next character with meaningful descriptions
		local next_chars = {}
		for shortcut_key, shortcut_data in pairs(potential_matches) do
			if #shortcut_key > #input then
				local next_char = shortcut_key:sub(#input + 1, #input + 1)
				if not next_chars[next_char] then
					-- Find a shortcut that starts with this character to show its name
					local example_shortcut = nil
					for key, data in pairs(potential_matches) do
						if key:sub(#input + 1, #input + 1) == next_char then
							example_shortcut = data
							break
						end
					end

					local desc = (action_verb or "Navigate to") ..
							" " .. (example_shortcut and example_shortcut.name or "directory")
					next_chars[next_char] = true
					table.insert(cands, { on = next_char, desc = desc })
				end
			end
		end

		-- Add escape option
		table.insert(cands, { on = "<Esc>", desc = "Cancel" })
		table.insert(cands, { on = "<C-c>", desc = "Cancel" })

		local choice = ya.which({
			cands = cands,
			silent = false
		})

		if not choice or choice > #cands - 2 then -- Last 2 are escape options
			return nil
		end

		local selected_key = cands[choice].on

		-- Check if this is a static shortcut on first key
		if input == "" and handle_static_shortcuts(selected_key) then
			return "handled"
		end

		input = input .. selected_key

		-- Check for exact match again
		if shortcuts[input] then
			return shortcuts[input]
		end
	end

	ya.notify({
		title = "Timeout",
		content = "Shortcut sequence too long",
		timeout = 2.0
	})
	return nil
end

local get_current_dir = ya.sync(function(state)
	return tostring(cx.active.current.cwd)
end)

local function perform_file_operation(operation, target_dir)
	ya.dbg("=== FILE OPERATION DEBUG ===")
	ya.dbg("Operation: " .. operation)
	ya.dbg("Target dir: " .. target_dir)

	-- Store current directory to return to it later
	local current_dir = get_current_dir()
	ya.dbg("Current dir: " .. current_dir)

	-- Use correct Yazi command names
	if operation == "copy" then
		ya.dbg("Executing copy operation")
		ya.emit("yank", {})
		ya.dbg("Yank completed")
		ya.emit("cd", { Url(target_dir) })
		ya.dbg("CD completed")
		ya.emit("paste", {})
		ya.dbg("Paste completed")

		-- Return to original directory after copy
		ya.emit("cd", { Url(current_dir) })
		ya.dbg("Returned to original directory")
	elseif operation == "move" then
		ya.dbg("Executing move operation")

		-- Use shell command with Yazi's built-in variables for move
		-- $@ represents all selected files, $0 represents hovered file
		-- No need to cd anywhere - just move the files directly
		local cmd = 'mv "$@" "' .. target_dir .. '" 2>/dev/null || mv "$0" "' .. target_dir .. '"'

		ya.dbg("Executing shell command: " .. cmd)
		ya.emit("shell", { cmd, "--block" })
		ya.dbg("Shell command completed - staying in current directory")
	end

	ya.dbg("=== FILE OPERATION END ===")
end

local function confirm_action(action, target_name)
	local message = string.format("%s selected files to %s?", action, target_name)

	return ya.confirm({
		title = "Confirm " .. action,
		content = message,
		pos = { "center", w = 50, h = 10 }
	})
end

return {
	setup = setup,
	entry = function(self, job)
		local action = job.args and job.args[1] or "navigate"

		if action == "navigate" then
			local shortcut = capture_keys("Navigate to")
			if shortcut and shortcut ~= "handled" then
				local target_url = Url(shortcut.dir)
				ya.emit("cd", { target_url })
			end
		elseif action == "copy" then
			local shortcut = capture_keys("Copy to")

			if shortcut and shortcut ~= "handled" then
				local confirmed = confirm_action("Copy", shortcut.name)

				if confirmed then
					perform_file_operation("copy", shortcut.dir)

					ya.notify({
						title = "Files copied",
						content = "Copied selected files to " .. shortcut.name,
						timeout = 2.0
					})
				end
			end
		elseif action == "move" then
			local shortcut = capture_keys("Move to")

			if shortcut and shortcut ~= "handled" then
				local confirmed = confirm_action("Move", shortcut.name)

				if confirmed then
					perform_file_operation("move", shortcut.dir)

					ya.notify({
						title = "Files moved",
						content = "Moved selected files to " .. shortcut.name,
						timeout = 2.0
					})
				end
			end
		end
	end,
}
