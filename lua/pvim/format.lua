require('lze').load {
        {
                "conform.nvim",
                for_cat = 'format',
                -- cmd = { "" },
                -- event = "",
                -- ft = "",
                keys = {
                        { "<leader>ff", desc = "[F]ormat [F]ile" },
                },
                -- colorscheme = "",
                after = function(plugin)
                        local conform = require("conform")

                        conform.setup({
                                formatters_by_ft = {
                                        lua        = { "stylua" },
                                        nix        = { "alejandra" },
                                        sh         = { "shfmt" },
                                        bash       = { "shfmt" },
                                        javascript = { "prettierd" },
                                        typescript = { "prettierd" },
                                        javascriptreact = { "prettierd" },
                                        typescriptreact = { "prettierd" },
                                        css        = { "prettierd" },
                                        html       = { "prettierd" },
                                        json       = { "prettierd" },
                                        yaml       = { "prettierd" },
                                toml       = { "taplo" },
                                        markdown   = { "prettierd" },
                                },
                        })



                        vim.keymap.set({ "n", "v" }, "<leader>ff", function()
                                conform.format({
                                        lsp_fallback = true,
                                        async = false,
                                        timeout_ms = 1000,
                                })
                        end, { desc = "[F]ormat [F]ile" })


                        -- Autocand dont work rn
                        -- vim.api.nvim_create_autocmd("BufWritePre", {
                        --        callback = function(args)
                        --                require("conform").format({
                        --                        lsp_fallback = true,
                        --                        async = false,
                        --                        timeout_ms = 1000,
                        --                })
                        --        end
                        --})
                end,
        },

}
