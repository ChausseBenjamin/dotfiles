local shortcuts_cache = {}
local shortcuts_loaded = false

local function load_shortcuts()
	if shortcuts_loaded then
		return shortcuts_cache
	end
	
	local shortcuts_file = os.getenv("HOME") .. "/.cache/shortcuts.lua"
	local file = io.open(shortcuts_file, "r")
	if not file then
		ya.notify({
			title = "Error",
			content = "Cannot open shortcuts file: " .. shortcuts_file,
			timeout = 3.0
		})
		return {}
	end
	
	local content = file:read("*all")
	file:close()
	
	local func, err = load(content)
	if not func then
		ya.notify({
			title = "Error",
			content = "Error parsing shortcuts.lua: " .. tostring(err),
			timeout = 3.0
		})
		return {}
	end
	
	local shortcuts = func()
	if not shortcuts then
		ya.notify({
			title = "Error", 
			content = "Shortcuts file did not return a table",
			timeout = 3.0
		})
		return {}
	end
	
	shortcuts_cache = {}
	for _, shortcut in ipairs(shortcuts) do
		if shortcut.keys and shortcut.dir then
			shortcuts_cache[shortcut.keys] = {
				dir = shortcut.dir,
				name = shortcut.name
			}
		end
	end
	
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
					
					local desc = (action_verb or "Navigate to") .. " " .. (example_shortcut and example_shortcut.name or "directory")
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
	entry = function(self, job)
		local action = job.args and job.args[1] or "navigate"
		
		if action == "navigate" then
			local shortcut = capture_keys("Navigate to")
			if shortcut and shortcut ~= "handled" then
				local target_url = Url(shortcut.dir)
				ya.emit("cd", { target_url })
			end
			-- If shortcut == "handled", the static shortcut was already executed
			
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