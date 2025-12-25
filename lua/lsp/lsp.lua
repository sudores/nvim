local capabilities = require('cmp_nvim_lsp').default_capabilities()
vim.lsp.config("gopls", {capabilities = capabilities})
vim.lsp.config("clangd", {capabilities = capabilities})
vim.lsp.config("pylsp", {capabilities = capabilities})
vim.lsp.config("terraformls", {capabilities = capabilities})
vim.lsp.config("vtsls", {capabilities = capabilities})
vim.lsp.config("marksman", {capabilities = capabilities})
vim.lsp.config("solidity", {capabilities = capabilities})
vim.lsp.config("bashls", {capabilities = capabilities})
vim.lsp.config("templ", {capabilities = capabilities})
vim.lsp.config("html", {capabilities = capabilities})
vim.lsp.config("cssls", {capabilities = capabilities})
vim.lsp.config("docker_compose_language_service", {capabilities = capabilities})
vim.lsp.config("dockerls", {capabilities = capabilities})
vim.lsp.config("pylsp", {capabilities = capabilities})
vim.lsp.config("helm_ls", {capabilities = capabilities})
vim.lsp.config("jsonls", {capabilities = capabilities})
vim.lsp.config("java-language-server", {capabilities = capabilities})
vim.lsp.config("lua_ls", {
    capabilities = capabilities,
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
          path = vim.split(package.path, ';'),
        },
        diagnostics = { globals = {'vim'} },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        completion = { callSnippet = "Replace" },
      },
    }
})

vim.lsp.config("yamlls", {
    capabilities = capabilities,
    settings = {
        yaml = {
            schemas = {
                --["file:///home/gz/memo/pln/goal/monthly.schema.json"] = "file:///home/gz/memo/pln/goal/goals/**/*.yaml",
            },
            validate = true,
            hover = true,
            completion = true,
            keyOrdering = false,
        },
    },
})
