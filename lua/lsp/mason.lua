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
        "ts_ls",
        "marksman",
        "solidity",
        "bashls",
        "templ",
        "html",
        "cssls",
        "docker_compose_language_service",
        "dockerls",
    },
}

