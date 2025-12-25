-- Auto run :TerraformFmt on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.tf",
  callback = function()
    -- Run the Vim command :TerraformFmt
    vim.cmd("TerraformFmt")
  end,
})

