local M = {}


---@type StatuscolumnOpts
M.default_opts = {
    excluded_filetypes = {
        "neo-tree",
        "help",
        "lazy",
        "man",
    },
    diagnostics = { collapsible = false },
    marks = { collapsible = false },
    line_number = {},
    git_signs = {},
}


return M
