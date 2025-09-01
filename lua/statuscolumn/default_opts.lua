local M = {}


---@type StatuscolumnOpts
M.default_opts = {
    enabled = true,
    excluded_filetypes = {
        "neo-tree",
        "help",
        "lazy",
        "man",
    },
    diagnostics = {
        enabled = true,
        minimum_width = 0,
    },
    marks = {
        enabled = true,
        minimum_width = 0,
    },
    line_number = {
        enabled = true,
        stable_width = true,
        minimum_width = 1,
        padding_right = " ",
    },
    git_signs = {
        enabled = true,
        border_colors = true,
    },
}


return M
