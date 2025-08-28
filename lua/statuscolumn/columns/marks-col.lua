local utils = require("statuscolumn.utils")
local cache = utils.Cache:new()

local M = {}


local marks_whitelist_patterns = {
    "%a",
    -- "%d", -- Apparently the getmarklist function doesn't find the 0-9 marks?
}


---Fills the marks cache.
---
local function generate_cache(context)
    cache:clear_buffer(context.draw_buffer)

    local marks = vim.fn.getmarklist(context.draw_buffer)

    for _, mark_obj in pairs(marks) do
        -- By default, marks are returned as "'m", we don't want the leading "'".
        local mark_label = string.sub(mark_obj.mark, -1)

        local is_whitelisted_mark = false
        for _, whitelist_pattern in pairs(marks_whitelist_patterns) do
            is_whitelisted_mark = string.find(mark_label, whitelist_pattern) ~= nil

            if is_whitelisted_mark then break end
        end

        if is_whitelisted_mark then
            local line_number = mark_obj.pos[2]
            cache:add_mark(context, line_number, mark_label)
        end
    end
end


--- Returns mark for the current line, or an empty space.
--- Note: there doesn't seem to be an event for "marks changed", so the only
--- "caching" we can do is by storing the marks for the buffer currently being
--- drawn.
---
---@param context Context
---@param options StatuscolumnMarksOpts
---@return string
function M.generate(context, options)
    if not options.enabled then return '' end

    if context.lnum == 1 and context.virtnum == 0 then
        generate_cache(context)
    end

    if context.virtnum ~= 0 then return "" end

    local mark = cache:get_mark(context) or ' '
    local colored_mark = utils.highlight_text("Constant", mark)

    return colored_mark
end


return M

