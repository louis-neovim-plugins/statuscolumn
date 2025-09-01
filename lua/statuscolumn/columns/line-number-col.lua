local utils = require("statuscolumn.utils")


local M = {}


---Calculates the "vertical size" of a wrapped line, i.e. How many actual lines it will occupy on the screen once it's wrapped.
---Credits to the author:
---https://www.reddit.com/r/neovim/comments/1ggwaho/multiline_showbreaklike_wrapping_symbols_in/
---
---@param context Context
---
---@return number
---
local function get_wrapped_line_height(context)
    local wo = vim.wo[context.draw_win_id]

    -- Get the width of the buffer.
    local winwidth = vim.api.nvim_win_get_width(context.draw_win_id)
    local numberwidth = wo.number and wo.numberwidth or 0
    local signwidth = vim.fn.exists("*sign_define") == 1 and vim.fn.sign_getdefined() and 2 or 0
    local foldwidth = wo.foldcolumn or 0

    local bufferwidth = winwidth - numberwidth - signwidth - foldwidth

    -- Fetch the line and calculate its display width.
    local line = vim.fn.getline(vim.v.lnum)
    local line_length = vim.fn.strdisplaywidth(line)

    return math.floor(line_length / bufferwidth)
end


---Determines the character to disply in the line number spot.
---Credits to the author:
---https://www.reddit.com/r/neovim/comments/1ggwaho/multiline_showbreaklike_wrapping_symbols_in/
---I made some minor alterations to work for both normal and relative line numbers.
---
---@param context Context
---@param options StatuscolumnLineNumberOpts
---
---@return string
---
local function get_text(context, options)
    local text = ""

    if context.virtnum < 0 then
        text = " "
    elseif context.virtnum > 0 then
        local num_wraps = get_wrapped_line_height(context)

        if context.virtnum == num_wraps then
            text = "└"
        else
            text = "│"
        end
    else
        if context.is_current_window then -- Relative or normal line numbers for current buffer.
            if context.is_cursor_line then
                text = tostring(context.cursor_line)
            elseif vim.o.relativenumber then
                text = tostring(vim.v.relnum)
            else
                text = tostring(vim.v.lnum)
            end
        else -- Normal line numbers for other buffers.
            text = tostring(vim.v.lnum)
        end
    end

    -- Add leading spaces to make the number stable in width no matter what it
    -- is.
    if options.stable_width then
        local max_line_number = vim.api.nvim_buf_line_count(context.draw_buffer)
        local length_diff = string.len(max_line_number) - vim.fn.strdisplaywidth(text)
        text = string.rep(" ", length_diff) .. text
    end

    -- Apply minimum width.
    local length_diff = options.minimum_width - vim.fn.strdisplaywidth(text)
    text = string.rep(" ", length_diff) .. text

    return text
end


---Determines the highlight group to be used for the line.
---
---@param context Context
---
---@return string
---
local function get_highlight_group(context)
    local cursorline_hl = "CursorLineNr"
    local line_hl = "LineNr"

    if context.is_cursor_line and context.is_current_window then
        return cursorline_hl
    else
        return line_hl
    end
end


--- Returns the symbol to be drawn in the line number column.
--- Will be the line number if it's the first actual line of a wrapped line.
--- Will return "scope symbols" otherwise.
--- The final number column should look like this:
--- 1
--- 2
--- │
--- │
--- └
--- 3
---
---@param context Context
---@param options StatuscolumnLineNumberOpts
---
---@return string
---
function M.generate(context, options)
    if not options.enabled then return "" end

    if not vim.wo[context.draw_win_id].number then return "" end

    local text = get_text(context, options)
    local hl_group = get_highlight_group(context)

    return utils.highlight_text(hl_group, text) .. options.padding_right
end


return M

