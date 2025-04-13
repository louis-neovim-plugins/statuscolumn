local extmarks = require("statuscolumn.extmarks")
local utils = require("statuscolumn.utils")
local td = require("throttle-debounce")

local M = {}

local border_icon = "▌"
local cached_ns_id = nil
local cache = utils.Cache:new()
local additional_signs_available = false

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



---Get the extmarks namespace id of the Gitsigns plugin.
---
---@return integer
local function get_ns_id()
  if not cached_ns_id then
    cached_ns_id = vim.api.nvim_get_namespaces()["gitsigns_signs_"]
  end

  return cached_ns_id
end


---Makes a dictionary indexed by line number for the git signs.
---Gitsigns creates either 0 or 1 sign for a given line.
---
---@return table<number, vim.api.keyset.extmark_details[]>
local function get_git_sign_details()
  local ns_id = get_ns_id()
  local signs = extmarks.get_signs_from_extmarks(ns_id)

  local signs_details_by_line = {}
  for _, sign in pairs(signs) do
    local line_number = sign[2] + 1
    local sign_detail = sign[4]
    signs_details_by_line[line_number] = { sign_detail }
  end

  return signs_details_by_line
end


---Gets the signs from cache or, if not present, from the extmarks.
---
---@param context Context
---@return table<number, vim.api.keyset.extmark_details[]>
local function get_cached_signs(context)
  local sign_details = cache:get_signs(context)
  if additional_signs_available or not sign_details then
    sign_details = get_git_sign_details()
    cache:add_signs(context, sign_details)

    additional_signs_available = false
  end

  return sign_details
end


---Given a list of Diagnostic symbols, returns the symbol with the highest
---severity.
---
---@param sign_details vim.api.keyset.extmark_details[]
---@return string
local function get_git_symbol_from_sign_details(sign_details)
    if not sign_details then
      return utils.highlight_text("NonText", border_icon)
    end

    -- There's at most one git sign for a given. Ever.
    return utils.highlight_text(sign_details[1].sign_hl_group, border_icon)
end


---Generates the symbol to be used in the gitsign colummn.
---
---@param context Context
---@return string
function M.generate(context)
  local symbol = nil

  if not additional_signs_available then
    symbol = cache:get_symbol(context)
  end

  if not symbol then
    local git_signs = get_cached_signs(context)

    local sign_details = git_signs[context.lnum]
    symbol = get_git_symbol_from_sign_details(sign_details)

    cache:add_symbol(context, symbol)
  end

  return symbol
end



-- AUTOCOMMANDS.
--


-- This is a debounced function, it will only trigger 150ms after the last call,
-- no matter how many times you call it.
local clear_cache = td.debounce_trailing(function(buffer_number)
  cache:clear_buffer(buffer_number)
  additional_signs_available = true
end, 150)


-- Gitsigns doesn't create extmarks for the entire buffer, only the visible
-- portion. So whenever we might see more of the buffer, we need to get the
-- extmarks again.
vim.api.nvim_create_autocmd({ "WinScrolled", "WinResized" }, {
  callback = function()
    additional_signs_available = true
  end,
})


-- Update when gitsigns signals that things have changed. This is completely
-- insufficient on its own.
-- :help gitsigns-events
vim.api.nvim_create_autocmd("User", {
  pattern = { "GitSignsUpdate", "GitSignsChanged" },
  callback = function(args)
    clear_cache(args.buf)
  end,
})


-- Forget all cache, when we bring nvim back from a background job. Because, we
-- might have used some git commands in the mean time, and it doesn't update
-- quite right.
vim.api.nvim_create_autocmd({ "VimResume" }, {
  callback = function()
    cache = utils.Cache:new()
    additional_signs_available = true
  end,
})


-- No sense in keeping the cache for a buffer that's no longer loaded.
vim.api.nvim_create_autocmd("BufDelete", {
  callback = function(args)
    cache:forget_buffer(args.buf)
  end,
})


return M

