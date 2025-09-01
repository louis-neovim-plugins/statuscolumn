---@class StatuscolumnOpts
---@field marks       StatuscolumnMarksOpts
---@field git_signs   StatuscolumnGitSignsOpts
---@field line_number StatuscolumnLineNumberOpts
---@field diagnostics StatuscolumnDiagnosticsOpts
---
---@field excluded_filetypes string[]
---@field enabled boolean Activate / deactivate the statuscolumn altogether.

---@class StatuscolumnMarksOpts
---@field enabled boolean Activate / deactivate the column altogether.
---@field minimum_width number The minimum width for the marks.

---@class StatuscolumnDiagnosticsOpts
---@field enabled boolean Activate / deactivate the column altogether.
---@field minimum_width number The minimum width for the diagnostics.

---@class StatuscolumnLineNumberOpts
---@field enabled boolean Activate / deactivate the column altogether.
---@field stable_width boolean Whether all line numbers should have the same
---width. i.e. '0' may be displayed as '  0' if your file has up to 999 lines.
---@field minimum_width number The minimum width forthe numbers. This can be
---superseeded by the 'stable_width' option if it is smaller, and can superseed
---it too if it is longer.
---@field padding_right string The padding character to add at the end of the
---line number.

---@class StatuscolumnGitSignsOpts
---@field enabled boolean Activate / deactivate the color on the border.
---@field hide_border boolean Deactivate the border itself. Effectively
---deactivating the column altogether.


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
---
---@field draw_win_id number Window id the statuscolumn function is currently drawing for.
---@field draw_buffer number Buffer number the statuscolumn function is currently drawing for.
---
---@field lnum number Line number the statuscolumn function is currently drawing for.
---@field relnum number Relative line number.
---@field virtnum number Virtual line number.
---@field first_visible_line number Number of the first visible line in the buffer.
---
---@field changedtick number Draw buffer changedtick value.
---@field vim_mode string Current vim mode.
---
---@field is_cursor_line boolean
---@field is_current_buffer boolean
---@field is_current_window boolean
---@field is_first_visible_line boolean


