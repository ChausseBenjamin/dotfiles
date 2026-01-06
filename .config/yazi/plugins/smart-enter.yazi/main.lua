--- @sync entry

-- Smart enter plugin for yazi
-- Enters directories (including symlinked directories) or opens files like pressing 'o'

local function smart_enter()
    local hovered = cx.active.current.hovered
    if not hovered then
        return
    end
    
    -- Check if it's a directory (including symlinked directories)
    if hovered.cha.is_dir then
        -- It's a directory, so enter it
        ya.mgr_emit("enter", {})
    else
        -- It's a file, so open it with the configured opener (same as 'o')
        ya.mgr_emit("open", { hovered = true })
    end
end

return {
    entry = smart_enter,
}