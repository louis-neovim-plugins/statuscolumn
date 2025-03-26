local extmarks = require("statuscolumn.extmarks")
local utils = require("statuscolumn.utils")
local td = require("throttle-debounce")

local M = {}

local border_icon = "▌"
local cached_ns_id = nil
local cache = utils.Cache:new()
local additional_signs_available = false


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


-- This is a debounced function, it will only trigger 150ms after the last call,
-- no matter how many times you call it.
local clear_cache = td.debounce_trailing(function(buffer_number)
  cache:clear_buffer(buffer_number)
  additional_signs_available = true
end, 150)


-- No need to clear the cache because the buffer hasn't changed. However.
-- Gitsigns only generates the signs for the visible portion of the buffer (and
-- I dont know of any event for this). So if we scroll around, we need to make
-- sure we fetch the signs again.
vim.api.nvim_create_autocmd("WinScrolled", {
  callback = function()
    additional_signs_available = true
  end,
})


-- :help gitsigns-events
vim.api.nvim_create_autocmd("User", {
  pattern = { "GitSignsUpdate", "GitSignsChanged" },
  callback = function(args)
    clear_cache(args.buf)
  end,
})


-- No sense in keeping the cache for a buffer that's no longer loaded.
vim.api.nvim_create_autocmd("BufDelete", {
  callback = function(args)
    cache:forget_buffer(args.buf)
  end,
})


return M

