local extmarks = require("statuscolumn.extmarks")
local utils = require("statuscolumn.utils")


local no_sign = " "

local M = {}
local cache = utils.Cache:new()


---Given a list of Diagnostic symbols, returns the symbol with the highest
---severity. e.g. If we have both a waning and an error on a given line, we
---would like to show the error sign rather than the warning sign.
---
---@param all_signs_details vim.api.keyset.extmark_details[]
---@return vim.api.keyset.extmark_details
local function get_highest_severity_sign(all_signs_details)

    -- Note: this has nothing to do with the `priority` field on signs.
    local priorities = {
        DiagnosticSignError = 4,
        DiagnosticSignWarn = 3,
        DiagnosticSignHint = 2,
        DiagnosticSignInfo = 1,
    }

    local highest_priority = 0
    local most_severe_sign_details = all_signs_details[1]

    for _, details in pairs(all_signs_details) do
        local hl_group = details.sign_hl_group
        local priority = priorities[hl_group]

        if priority and priority > highest_priority then
            highest_priority = priority
            most_severe_sign_details = details
        end
    end

    return most_severe_sign_details
end


---Get the diagnostic sign details from extmarks or the cache (faster).
---
---@param context Context
---@return table<number, vim.api.keyset.extmark_details[]>
local function get_cached_signs(context)
    local sign_details = cache:get_signs(context)
    if not sign_details then
        sign_details = extmarks.get_diagnostic_sign_details()
        cache:set_signs(context, sign_details)
    end

    return sign_details
end


---Generate the diagnostic part of a status column.
---
---@param context Context
---@param options StatuscolumnDiagnosticsOpts
---@return string
function M.generate(context, options)
    if not options.enabled then return "" end

    if not vim.diagnostic.is_enabled() then return no_sign end

    local symbol = cache:get_symbol(context)
    if symbol then return symbol end

    local all_signs_details = get_cached_signs(context)
    local line_diagnostic_signs = all_signs_details[context.lnum]
    if line_diagnostic_signs == nil or vim.tbl_count(line_diagnostic_signs) == 0 then return no_sign end

    local sign_details = get_highest_severity_sign(line_diagnostic_signs)

    local text = ""
    if context.virtnum < 0 then
        if context.virtnum == -1 then
            text = "└"
        else
            text = "│"
        end
    else
        text = sign_details.sign_text:gsub("%s+", "")
    end

    symbol = utils.highlight_text(sign_details.sign_hl_group, text)
    cache:add_symbol(context, symbol)

    return symbol
end


-- This is the cache invalidation part of the caching mechanism.
--
-- If you simply cache based on `changedtcik`, the statuscolumn is drawn before
-- the diagnostics have time to update. Thus you will not have the correct
-- signs.
--
-- Luckily an event is triggered when the diagnostics update. And when they do,
-- we clear the cache.
--
-- A redraw call apparently isn't needed. I suppose it's already queued when we
-- get the event.
--
-- And we also need a little help when levaing insert mode, apparently the
-- diagnostics changed event isn't fired.
vim.api.nvim_create_autocmd({ 'DiagnosticChanged', 'InsertLeave' }, {
    callback = function(args)
        cache:clear_buffer(args.buf)
    end,
})


-- No sense in keeping the cache for a buffer that's no longer loaded.
vim.api.nvim_create_autocmd('BufDelete', {
    callback = function(args)
        cache:forget_buffer(args.buf)
    end,
})


return M

