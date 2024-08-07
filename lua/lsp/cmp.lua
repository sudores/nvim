local cmp_status, cmp = pcall(require, "cmp")
if not cmp_status then
  return
end

local luasnip_status, luasnip = pcall(require, "luasnip")
if not luasnip_status then
  return
end

require("luasnip/loaders/from_vscode").lazy_load()

vim.opt.completeopt = "menu,menuone,noselect"
vim.api.nvim_set_hl(0, "CmpNormal", { bg = "#2E3540", blend=20 })
vim.api.nvim_set_hl(0, "CmpDocNormal", { bg = "#2e3542", blend=20 })

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
    ["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-l>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
    ["<C-e>"] = cmp.mapping.abort(), -- close completion window
    ["<C-f>"] = cmp.mapping.confirm({ select = false }),
  }),
  -- sources for autocompletion
  sources = cmp.config.sources({
    { name = "nvim_lsp" }, -- LSP
    { name = "luasnip" }, -- snippets
    { name = "buffer" }, -- text within the current buffer
    { name = "path" }, -- file system paths
    { name = 'nvim_lsp_signature_help' }, -- signature help
  }),
  window = {
    completion = {
        winhighlight = "Normal:CmpNormal,CursorLine:CmpCursorLine,Search:None",
    },
    documentation = {
        winhighlight = "Normal:CmpDocNormal",
   }
  }
})
