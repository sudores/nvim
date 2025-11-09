return {
    'tpope/vim-speeddating',
    version = false,
    config = function ()
        vim.api.nvim_create_autocmd("VimEnter", {
          pattern = "*",
          command = "SpeedDatingFormat %d-%m-%Y",
        })
        vim.api.nvim_create_autocmd("VimEnter", {
          pattern = "*",
          command = "SpeedDatingFormat %Y-%m",
        })
        vim.api.nvim_create_autocmd("VimEnter", {
          pattern = "*",
          command = "SpeedDatingFormat %m.%d",
        })
    end,
}
