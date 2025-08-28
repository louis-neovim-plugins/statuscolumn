local M = {}


---@type StatuscolumnOpts
M.default_opts = {
    enabled = true,
    padding_before_border = " ",
    excluded_filetypes = {
        "neo-tree",
        "help",
        "lazy",
        "man",
    },
    diagnostics = {
        enabled = true,
        collapsible = false,
    },
    marks = {
        enabled = true,
        collapsible = true,
    },
    line_number = {
        enabled = true,
    },
    git_signs = {
        enabled = true,
    },
}


return M
