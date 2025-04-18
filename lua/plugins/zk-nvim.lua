return {
  "zk-org/zk-nvim",
  config = function()
        require("zk").setup({
          -- Can be "telescope", "fzf", "fzf_lua", "minipick", "snacks_picker",
          -- or select" (`vim.ui.select`). It's recommended to use "telescope",
          -- "fzf", "fzf_lua", "minipick", or "snacks_picker".
          picker = "select",

          lsp = {
            -- `config` is passed to `vim.lsp.start_client(config)`
            config = {
              cmd = { "/home/gz/.local/bin/zk", "lsp" },
              name = "zk",
              -- on_attach = ...
              -- etc, see `:h vim.lsp.start_client()`
              filetypes = { "markdown" },
              autostart = true,
            },

            -- automatically attach buffers in a zk notebook that match the given filetypes
            auto_attach = {
              enabled = true,
              filetypes = { "markdown" },
            },
          },
        })
  end
}
