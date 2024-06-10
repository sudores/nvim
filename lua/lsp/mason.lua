require("mason").setup()
require("mason-lspconfig").setup()

require("mason-lspconfig").setup {
    ensure_installed = {
        "lua_ls",
        "gopls",
        "clangd",
        "arduino_language_server",
        "pylsp",
        "terraformls",
        "tsserver",
        "marksman",
        "solidity",
        "bashls",
    },
}

