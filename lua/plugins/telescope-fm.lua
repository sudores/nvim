return {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    config = function ()
        require("telescope").setup({
            extensions = {
                file_browser = {
                    theme = "ivy",
                }
            }
        })
        require("telescope").load_extension("file_browser")
    end
}
