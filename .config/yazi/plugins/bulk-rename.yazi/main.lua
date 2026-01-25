local get_files = ya.sync(function()
	local files = {}
	local selected = cx.active.selected

	ya.dbg("Selected count: " .. #selected)

	-- If files are selected, use only those; otherwise use all files in current directory
	if #selected > 0 then
		ya.dbg("Using selected files")
		for _, file in pairs(selected) do
			table.insert(files, file.name)
			ya.dbg("Selected file: " .. file.name)
		end
	else
		ya.dbg("Using all files in directory")
		-- Use current folder's files - iterate by index, not pairs()
		local current = cx.active.current
		if current and current.files then
			ya.dbg("Files count: " .. #current.files)
			for i = 1, #current.files do
				local file = current.files[i]
				if not file.cha.is_dir then
					table.insert(files, file.name)
					ya.dbg("Directory file: " .. file.name)
				end
			end
		else
			ya.dbg("No current.files found")
		end
	end

	ya.dbg("Total files for rename: " .. #files)
	return files
end)

local get_current_dir = ya.sync(function()
	return tostring(cx.active.current.cwd)
end)

local function entry()
	ya.dbg("=== BULK RENAME PLUGIN START ===")

	local files = get_files()

	if #files == 0 then
		ya.dbg("No files to rename - showing notification")
		ya.notify({
			title = "Bulk Rename",
			content = "No files to rename",
			timeout = 3.0,
			level = "warn"
		})
		return
	end

	-- Create temporary files
	local tmpfile_old = os.tmpname()
	local tmpfile_new = os.tmpname()

	ya.dbg("Temp files: " .. tmpfile_old .. " | " .. tmpfile_new)

	-- Write file list to both temp files
	local file_list = table.concat(files, "\n") .. "\n"
	ya.dbg("File list content:\n" .. file_list)

	local f = io.open(tmpfile_old, "w")
	if f then
		f:write(file_list)
		f:close()
		ya.dbg("Written to tmpfile_old successfully")
	else
		ya.dbg("Failed to write tmpfile_old")
		ya.notify({
			title = "Bulk Rename",
			content = "Failed to create temp file",
			timeout = 3.0,
			level = "error"
		})
		return
	end

	f = io.open(tmpfile_new, "w")
	if f then
		f:write(file_list)
		f:close()
		ya.dbg("Written to tmpfile_new successfully")
	else
		ya.dbg("Failed to write tmpfile_new")
		ya.notify({
			title = "Bulk Rename",
			content = "Failed to create temp file",
			timeout = 3.0,
			level = "error"
		})
		return
	end

	-- Get editor and open the temp file
	local editor = os.getenv("EDITOR") or "nano"
	ya.dbg("Using editor: " .. editor)
	ya.dbg("About to execute editor command...")

	-- Hide Yazi and give control to the terminal
	local permit = ui.hide()

	-- Run the editor synchronously and wait for it to complete
	-- Use stdin/stdout/stderr inheritance to ensure proper TTY interaction
	local status, err = Command(editor)
			:arg(tmpfile_new)
			:stdin(Command.INHERIT)
			:stdout(Command.INHERIT)
			:stderr(Command.INHERIT)
			:status()

	-- Restore Yazi interface
	permit:drop()

	if err then
		ya.err("Failed to run editor: " .. tostring(err))
		return
	end

	ya.dbg("Editor exit status: success=" .. tostring(status.success) .. ", code=" .. tostring(status.code))

	if not status.success then
		ya.err("Editor exited with non-zero status: " .. tostring(status.code or "unknown"))
		return
	end

	ya.dbg("Editor completed successfully")

	-- Read both files to compare
	local old_names = {}
	local new_names = {}

	f = io.open(tmpfile_old, "r")
	if f then
		for line in f:lines() do
			if line ~= "" then
				table.insert(old_names, line)
			end
		end
		f:close()
		ya.dbg("Read " .. #old_names .. " old names")
	end

	f = io.open(tmpfile_new, "r")
	if f then
		for line in f:lines() do
			if line ~= "" then
				table.insert(new_names, line)
			end
		end
		f:close()
		ya.dbg("Read " .. #new_names .. " new names")
	end

	-- Safety check: line count must match
	if #old_names ~= #new_names then
		ya.dbg("Line count mismatch: " .. #old_names .. " vs " .. #new_names)
		ya.notify({
			title = "Bulk Rename",
			content = "Error: Number of lines changed. Aborting.",
			timeout = 5.0,
			level = "error"
		})
		os.remove(tmpfile_old)
		os.remove(tmpfile_new)
		return
	end

	-- Perform renames
	local renamed_count = 0
	local current_dir = get_current_dir()
	ya.dbg("Current directory: " .. current_dir)

	for i = 1, #old_names do
		local old_name = old_names[i]
		local new_name = new_names[i]

		ya.dbg("Processing: " .. old_name .. " -> " .. new_name)

		if old_name ~= new_name and new_name ~= "" then
			local old_path = current_dir .. "/" .. old_name
			local new_path = current_dir .. "/" .. new_name

			ya.dbg("Paths: " .. old_path .. " -> " .. new_path)

			-- Check if target exists
			local new_cha, _ = fs.cha(Url(new_path))
			if not new_cha then
				-- Perform rename
				if os.rename(old_path, new_path) then
					renamed_count = renamed_count + 1
					ya.dbg("Renamed successfully: " .. old_name .. " -> " .. new_name)
				else
					ya.dbg("Failed to rename: " .. old_name)
					ya.notify({
						title = "Bulk Rename",
						content = "Failed to rename: " .. old_name,
						timeout = 3.0,
						level = "error"
					})
				end
			else
				ya.dbg("Target exists, skipping: " .. new_name)
				ya.notify({
					title = "Bulk Rename",
					content = "Target exists, skipping: " .. new_name,
					timeout = 3.0,
					level = "warn"
				})
			end
		end
	end

	-- Cleanup
	os.remove(tmpfile_old)
	os.remove(tmpfile_new)
	ya.dbg("Cleaned up temp files")

	-- Refresh Yazi
	ya.emit("refresh", {})
	ya.dbg("Emitted refresh")

	if renamed_count > 0 then
		ya.dbg("Success: renamed " .. renamed_count .. " files")
		ya.notify({
			title = "Bulk Rename",
			content = string.format("Renamed %d file(s)", renamed_count),
			timeout = 3.0,
			level = "info"
		})
	else
		ya.dbg("No files were renamed")
		ya.notify({
			title = "Bulk Rename",
			content = "No files were renamed",
			timeout = 3.0,
			level = "info"
		})
	end

	ya.dbg("=== BULK RENAME PLUGIN END ===")
end

return {
	entry = entry
}

