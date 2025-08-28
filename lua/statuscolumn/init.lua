local line_number_col = require("statuscolumn.line-number-col")
local gitsign_col = require("statuscolumn.gitsign-col")
local diagnostics_col = require("statuscolumn.diagnostic-col")
local marks_col = require("statuscolumn.marks-col")

local default_opts = {
  excluded_filetypes = {
    "neo-tree",
    "help",
    "lazy",
    "man",
  },
}

local final_opts = default_opts


---Merges the user options with the default options.
---
---@param opts StatuscolumnOpts
local function process_opts(opts)
  if opts.excluded_filetypes then
    final_opts.excluded_filetypes = opts.excluded_filetypes
  end
end


---Decides if the statusbar should be drawn for the buffer that's being drawn by
---Neovim.
---
---@param context Context
---@return boolean
local function is_excluded_filetype(context)
  return vim.tbl_contains(
    final_opts.excluded_filetypes,
    vim.bo[context.draw_buffer].filetype
  )
end


---General "context" container with pretty much all of the information you want
---to draw the statuscolumn.
---
---@class Context
---@field cursor_win_id number Window id where the cursor currently is.
---@field cursor_buffer number Buffer number where the cursor currently is.
---@field cursor_line number Line number of the cursor.
---@field draw_win_id number Window id the statuscolumn function is currently drawing for.
---@field draw_buffer number Buffer number the statuscolumn function is currently drawing for.
---@field lnum number Line number the statuscolumn function is currently drawing for.
---@field relnum number Relative line number.
---@field virtnum number Virtual line number.
---@field changedtick number Draw buffer changedtick value.
---@field vim_mode string Current vim mode.
---@field is_cursor_line boolean
---@field is_current_buffer boolean
---@field is_current_window boolean


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
---This function will be called once per line. Be mindful of performance costs.
---This needs to be a global function for the statuscolumn to be able to call
---it.
---@return string
function Generate_statuscolumn()
  local context = get_context()

  if is_excluded_filetype(context) then
    return ""
  end

  -- :help statuscolumn
  -- :help statusline
  local components = {
    marks_col.generate(context),
    diagnostics_col.generate(context),
    -- Switch alignment. i.e. Segments above are aligned to the left. Segments
    -- below are aligned to the right.
    "%=",
    line_number_col.generate(context),
    -- Just some spacing before the border.
    " ",
    gitsign_col.generate(context),
  }

  return table.concat(components)
end


local M = {}

---Configures nvim with the statuscolumn.
---
---@param opts StatuscolumnOpts
function M.setup(opts)
  process_opts(opts)

  vim.opt.statuscolumn = "%!v:lua.Generate_statuscolumn()"
end

return M

