local utils = require("statuscolumn.utils")


local M = {}


local marks_whitelist_patterns = {
  "%a",
  -- "%d", -- Apparently the getmarklist function doesn't find the 0-9 makrs?
}


--- Returns mark for the current line, or an empty space.
---
---@param context Context
---@return string
function M.generate(context)
  local marks = vim.fn.getmarklist("%")

  local marks_by_line = {}
  for _, mark_obj in pairs(marks) do
    local mark_label = string.sub(mark_obj.mark, -1)

    local is_whitelisted_mark = false
    for _, whitelist_pattern in pairs(marks_whitelist_patterns) do
      is_whitelisted_mark = string.find(mark_label, whitelist_pattern) ~= nil

      if is_whitelisted_mark then break end
    end

    if is_whitelisted_mark then
      local line_number = mark_obj.pos[2]
      marks_by_line[line_number] = mark_label
    end
  end

  local count = vim.tbl_count(marks_by_line)
  if count == 0 then
    return ''
  end

  local mark = marks_by_line[context.lnum] or ' '

  local colored_mark = utils.highlight_text("Constant", mark)

  return colored_mark
end


return M

