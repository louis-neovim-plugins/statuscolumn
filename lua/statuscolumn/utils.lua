
local M = {}


---Highlight a string with the given highlight group.
---
---@param highlight_group string Highlight group name.
---@param text string String to be hihglighted.
---@return string highlighted_string
function M.highlight_text(highlight_group, text)
  return table.concat({ "%#", highlight_group, "#", text, "%*" })
end


---Caching structure for signs.
---signs_cache is buffer_number -> changedtick -> line_number -> sign_details.
---symbols_cache is buffer_number -> line_number -> symbol.
---
---@class Cache
---@field signs_cache table<number, table<number, table<number, vim.api.keyset.extmark_details[]>>>
---@field symbols_cache table<number, table<number, string>>
M.Cache = {}


---Creates a new cache instance.
---
---@return Cache cache_structure
function M.Cache:new()
  local props = { signs_cache = {}, symbols_cache = {} }
  local newObject = setmetatable(props, self)
  self.__index = self

  return newObject
end


---Fetches the sign_details index for a given context.
---Basically cache.buffer.changedtick
---
---@param context Context
---@return table<number, vim.api.keyset.extmark_details[]>|nil
function M.Cache:get_signs(context)
  local buffer_cache = self.signs_cache[context.draw_buffer] or {}
  local changedtick_cache = buffer_cache[context.changedtick]

  return changedtick_cache
end


---Sets the cached value for a given draw buffer plus changedtick combination. Overwrites all previous values for the current changedtick. Previous changedtick values are erased.
---
---@param context Context
---@param sign_details_by_line_number table<number, vim.api.keyset.extmark_details[]>
function M.Cache:set_signs(context, sign_details_by_line_number)
  -- Note that we overwrite any previously set cache.
  self.signs_cache[context.draw_buffer] = {
    [context.changedtick] = sign_details_by_line_number,
  }
end


---Adds values to a given draw buffer plus changedtick combination. Values for a given line may be overwritten.
---
---@param context Context
---@param sign_details_by_line_number table<number, vim.api.keyset.extmark_details[]>
function M.Cache:add_signs(context, sign_details_by_line_number)
  local buffer_cache = self.signs_cache[context.draw_buffer] or {}
  local existing_signs_cache = buffer_cache[context.changedtick] or {}

  -- Note that cached values for a given line number will be overwritten.
  self.signs_cache[context.draw_buffer] = {
    [context.changedtick] = vim.tbl_deep_extend("force",
      existing_signs_cache,
      sign_details_by_line_number
    )
  }
end


---Fetches the sign_details index for a given context.
---Basically cache.buffer.changedtick
---
---@param context Context
---@return string|nil
function M.Cache:get_symbol(context)
  local buffer_cache = self.symbols_cache[context.draw_buffer] or {}
  local symbol = buffer_cache[context.lnum]

  return symbol
end


---Stores a value in the cache.
---@param context Context
---@param symbol string
function M.Cache:set_symbol(context, symbol)
  -- Note that we overwrite any previously set cache.
  self.symbols_cache[context.draw_buffer] = {
    [context.lnum] = symbol,
  }
end


---Adds a symbol to a given draw buffer. The value for a given line may be overwritten.
---
---@param context Context
---@param symbol string
function M.Cache:add_symbol(context, symbol)
  local buffer_cache = self.symbols_cache[context.draw_buffer] or {}

  buffer_cache[context.lnum] = symbol

  self.symbols_cache[context.draw_buffer] = buffer_cache
end


---Clears both cache contents for a given buffer.
---@param buffer_number number
function M.Cache:clear_buffer(buffer_number)
  self.signs_cache[buffer_number] = {}
  self.symbols_cache[buffer_number] = {}
end


---Completely forgets a buffer. The buffer key should no longer show up in the cache.
---
---@param buffer_number number
function M.Cache:forget_buffer(buffer_number)
  self.signs_cache[buffer_number] = nil
  self.symbols_cache[buffer_number] = nil
end


return M

