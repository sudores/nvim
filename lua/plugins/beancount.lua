return {
    "hxueh/beancount.nvim",
    ft = { "beancount", "bean" },
    dependencies = {
        {
            "L3MON4D3/LuaSnip",
        },
    },
    config = function()
        require("beancount").setup({})
    end,
}
