

---@class StatuscolumnOpts
---@field marks       StatuscolumnMarksOpts
---@field git_signs   StatuscolumnGitSignsOpts
---@field line_number StatuscolumnLineNumberOpts
---@field diagnostics StatuscolumnDiagnosticsOpts
---
---@field excluded_filetypes string[]
---@field enabled boolean Activate / deactivate the statuscolumn altogether.
---@field padding_before_border string The padding character to add just before
---the border column (git sign column).

---@class StatuscolumnMarksOpts
---@field enabled boolean Activate / deactivate the column altogether.
---@field collapsible boolean Whether the column should collapse if empty.

---@class StatuscolumnDiagnosticsOpts
---@field enabled boolean Activate / deactivate the column altogether.
---@field collapsible boolean Whether the column should collapse if empty.

---@class StatuscolumnLineNumberOpts
---@field enabled boolean Activate / deactivate the column altogether.

---@class StatuscolumnGitSignsOpts
---@field enabled boolean Activate / deactivate the column altogether.


--- Top level Statuscolumn options container for the user.
---
---@class (partial) UserStatuscolumnOpts: StatuscolumnOpts
-- The '(partial)' annotations here is a rough equivalent of Typescript's
-- 'Partial<T>'.
-- https://github.com/LuaLS/lua-language-server/pull/3024


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


