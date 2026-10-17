local M = {}

local function clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

M.greet = function(name)
    local msg = string.format("Hello, %s!", name)
    vim.notify(msg, vim.log.levels.INFO)
    return msg
end

M.setup = function(opts)
    opts = opts or {}
    local defaults = {
        width = 80,
        height = 24,
        enabled = true,
    }
    local config = vim.tbl_deep_extend("force", defaults, opts)
    config.width = clamp(config.width, 20, 200)
    return config
end

local State = {}
State.__index = State

function State.new(initial)
    return setmetatable({ value = initial, history = {} }, State)
end

function State:set(val)
    table.insert(self.history, self.value)
    self.value = val
end

function State:undo()
    if #self.history == 0 then return end
    self.value = table.remove(self.history)
end

local numbers = vim.tbl_map(function(n)
    return n * n
end, { 1, 2, 3, 4, 5 })

local even = vim.tbl_filter(function(n)
    return n % 2 == 0
end, numbers)

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.lua",
    callback = function(args)
        local bufnr = args.buf
        vim.lsp.buf.format({ bufnr = bufnr, async = false })
    end,
})

return M
