require('lze').load {
        {
                "nvim-lint",
                for_cat = 'lint',
                -- cmd = { "" },
                event = "FileType",
                -- ft = "",
                -- keys = "",
                -- colorscheme = "",
                after = function(plugin)
                        require('lint').linters_by_ft = {
                                javascript      = { 'eslint' },
                                typescript      = { 'eslint' },
                                sh              = { 'shellcheck' },
                                bash            = { 'shellcheck' },
                                nix             = { 'statix' },
                                yaml            = { 'yamllint' },
                                markdown        = { 'markdownlint-cli2' },
                        }

                        vim.api.nvim_create_autocmd({ "InsertLeave", "BufWritePost" }, {
                                callback = function()
                                        require("lint").try_lint()
                                end,
                        })
                end,
        },
}
