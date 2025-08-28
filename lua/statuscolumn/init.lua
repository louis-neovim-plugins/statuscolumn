local default_opts = require("statuscolumn.default_opts").default_opts

local line_number_col = require("statuscolumn.columns.line-number-col")
local gitsign_col = require("statuscolumn.columns.gitsign-col")
local diagnostics_col = require("statuscolumn.columns.diagnostic-col")
local marks_col = require("statuscolumn.columns.marks-col")


local M = {}


---Merges the user options with the default options.
---
---@param opts UserStatuscolumnOpts
local function process_opts(opts)
    M.final_opts = vim.tbl_deep_extend("force", default_opts, opts)
end


---Decides if the statusbar should be drawn for the buffer that's being drawn by
---Neovim.
---
---@param context Context
---@return boolean
local function is_excluded_filetype(context)
    return vim.tbl_contains(
        M.final_opts.excluded_filetypes,
        vim.bo[context.draw_buffer].filetype
    )
end


---Gathers a bunch of useful information for generating a statuscolumn.
---
---@return Context
local function get_context()
    local draw_buffer = vim.api.nvim_win_get_buf(vim.g.statusline_winid)

    local context = {
        cursor_win_id = vim.api.nvim_get_current_win(),
        cursor_buffer = vim.api.nvim_win_get_buf(0),
        cursor_line = unpack(vim.api.nvim_win_get_cursor(0)),

        draw_win_id = vim.g.statusline_winid,
        draw_buffer = draw_buffer,
        lnum = vim.v.lnum,
        relnum = vim.v.relnum,
        virtnum = vim.v.virtnum,

        changedtick = vim.api.nvim_buf_get_changedtick(draw_buffer),
        vim_mode = vim.api.nvim_get_mode().mode,
    }

    local is_cursor_line = context.lnum == context.cursor_line
    local is_current_buffer = context.draw_buffer == context.cursor_buffer
    local is_current_window = context.draw_win_id == context.cursor_win_id

    context.is_cursor_line = is_cursor_line
    context.is_current_buffer = is_current_buffer
    context.is_current_window = is_current_window

    return context
end


---Creates the statuscolumn: diagnostic sign > line number > border that doubles
---as a git indicator.
---e.g. ' 24 ▌'
---
---This function will be called once per line for all visible windows. Be
---mindful of performance costs. This needs to be a global function for the
---statuscolumn to be able to call it.
---
---@return string
function Generate_statuscolumn()
    if not M.final_opts.enabled then return "" end

    local context = get_context()
    if is_excluded_filetype(context) then return "" end

    -- :help statuscolumn
    -- :help statusline
    local components = {
        marks_col.generate(context, M.final_opts.marks),
        diagnostics_col.generate(context, M.final_opts.diagnostics),
        -- Switch alignment. i.e. Segments above are aligned to the left. Segments
        -- below are aligned to the right.
        "%=",
        line_number_col.generate(context, M.final_opts.line_number),
        M.final_opts.padding_before_border,
        gitsign_col.generate(context, M.final_opts.git_signs),
    }

    return table.concat(components)
end


---Configures nvim with the statuscolumn.
---
---@param opts UserStatuscolumnOpts
function M.setup(opts)
    process_opts(opts)

    vim.opt.statuscolumn = "%!v:lua.Generate_statuscolumn()"
end


return M

