local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()
--local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
lspconfig.gopls.setup({capabilities = capabilities})
lspconfig.lua_ls.setup({capabilities = capabilities})
lspconfig.clangd.setup({capabilities = capabilities})
lspconfig.pylsp.setup({capabilities = capabilities})
lspconfig.terraformls.setup({capabilities = capabilities})
lspconfig.vtsls.setup({capabilities = capabilities})
lspconfig.marksman.setup({capabilities = capabilities})
lspconfig.solidity.setup({capabilities = capabilities})
lspconfig.bashls.setup({capabilities = capabilities})
lspconfig.templ.setup({capabilities = capabilities})
lspconfig.html.setup({capabilities = capabilities})
lspconfig.cssls.setup({capabilities = capabilities})
lspconfig.docker_compose_language_service.setup({capabilities = capabilities})
lspconfig.dockerls.setup({capabilities = capabilities})

--local ardu_capabilities = require('cmp_nvim_lsp').default_capabilities()
--ardu_capabilities.textDocument.semanticTokens = vim.NIL
--ardu_capabilities.workspace.semanticTokens = vim.NIL
--require'lspconfig'.arduino_language_server.setup{capabilities = ardu_capabilities}
--
--require("arduino-nvim").setup({
--        default_fqbn = "arduino:avr:nano",
--        clangd = nil, -- path to a clangd executable
--        arduino = nil, -- path to a arduino-cli executable
--        extra_args = nil, -- command line args to arduino lsp
--        root_dir = nil,
--        capabilities = nil,
--        filetypes = {"arduino"},
--        callbacks = {
--            on_attach = nil
--        }
--})
--
