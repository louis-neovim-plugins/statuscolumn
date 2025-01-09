
local M = {}


---It looks like the Neovim lua type annotations are incorrect. Let's fix them.
---@class Sign: vim.api.keyset.get_extmark_item
---@field [4] vim.api.keyset.extmark_details


---Fetches all signs in the window being drawn in the provided namespace, or all namespaces by default.
---
---@param namespace_id? number
---@return Sign[]
function M.get_signs_from_extmarks(namespace_id)
  -- This is the buffer number of the buffer we are currently drawing the statuscolumn for.
  local buffer_number = vim.api.nvim_win_get_buf(vim.g.statusline_winid)

  return vim.api.nvim_buf_get_extmarks(
    buffer_number,  -- Current buffer.
    namespace_id or -1, -- Provided namespace or all namespaces.
    0,  -- First line and column.
    -1, -- Last line and column.
    {
      type = "sign",
      details = true,
    }
  )
end


---Extracts diganostic signs from all signs and index them by line number.
---We recognize signs by their highlight group (not ideal).
---
---@param signs Sign[]
---@return table<number, vim.api.keyset.extmark_details[]>
local function get_diagnostic_signs_index(signs)
  local diagnostic_hl_groups = {
    "DiagnosticSignError",
    "DiagnosticSignWarn",
    "DiagnosticSignHint",
    "DiagnosticSignInfo",
  }
  local diagnostic_signs = {}

  for _, sign in pairs(signs) do
    -- + 1 because extmarks are 0 based, while line numbers are 1 based.
    -- :help api-indexing
    local line_number = sign[2] + 1
    local sign_detail = sign[4]

    if vim.tbl_contains(diagnostic_hl_groups, sign_detail.sign_hl_group) then
      if not diagnostic_signs[line_number] then
        diagnostic_signs[line_number] = {}
      end

      table.insert(diagnostic_signs[line_number], sign_detail)
    end
  end

  return diagnostic_signs
end


---Returns the diagnostic signs grouped by line number.
---There may be multiple signs for a given line number.
---
---@return table<number, vim.api.keyset.extmark_details[]>
function M.get_diagnostic_sign_details()
  local all_signs = M.get_signs_from_extmarks()
  return get_diagnostic_signs_index(all_signs)
end


return M

