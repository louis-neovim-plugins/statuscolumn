local utils = require("statuscolumn.utils")
local cache = utils.Cache:new()

local M = {}


local marks_whitelist_patterns = {
    "%a", -- a-z marks.
}


---Fills the marks cache.
---
---@param context Context
---
local function generate_cache(context)
    cache:clear_buffer(context.draw_buffer)

    -- Handle global marks: A-Z and 0-9.
    local global_marks = vim.fn.getmarklist()
    local current_buffer_name = vim.api.nvim_buf_get_name(context.draw_buffer)
    for _, mark in pairs(global_marks) do
        local mark_label = string.sub(mark.mark, -1)
        local mark_buffer_name = vim.api.nvim_buf_get_name(mark.pos[1])

        if mark_buffer_name == current_buffer_name then
            local line_number = mark.pos[2]
            cache:add_mark(context, line_number, mark_label)
        end
    end

    -- Handle local marks: a-z.
    local marks = vim.fn.getmarklist(context.draw_buffer)
    for _, mark in pairs(marks) do
        -- By default, marks are returned as "'m", we don't want the leading "'".
        local mark_label = string.sub(mark.mark, -1)

        local is_whitelisted_mark = false
        for _, whitelist_pattern in pairs(marks_whitelist_patterns) do
            is_whitelisted_mark = string.find(mark_label, whitelist_pattern) ~= nil

            if is_whitelisted_mark then break end
        end

        if is_whitelisted_mark then
            local line_number = mark.pos[2]
            cache:add_mark(context, line_number, mark_label)
        end
    end
end


--- Returns mark for the current line, or an empty string.
--- Note: there doesn't seem to be an event for "marks changed", so the only
--- "caching" we can do is by storing the marks for the buffer currently being
--- drawn. So we regenerate the cache every time we draw the column for the
--- first visible line only. And then reuse the cache for all other lines.
---
---@param context Context
---@param options StatuscolumnMarksOpts
---
---@return string
---
function M.generate(context, options)
    if not options.enabled then return "" end

    if context.virtnum ~= 0 then return "" end

    if context.is_first_visible_line then
        generate_cache(context)
    end

    local mark = cache:get_mark(context) or " "
    local colored_mark = utils.highlight_text("Constant", mark)

    return colored_mark
end


return M

