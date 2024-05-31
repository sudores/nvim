return {
    'fatih/vim-go',
    lazy = false,
    priority = 1000,
    dependencies = {},
    config = function ()
-- Highlight settings
vim.g.go_highlight_fields = 1
vim.g.go_highlight_functions = 1
vim.g.go_highlight_function_calls = 1
vim.g.go_highlight_extra_types = 1
vim.g.go_highlight_operators = 1

-- Auto formatting and importing
vim.g.go_fmt_autosave = 1
vim.g.go_fmt_command = "goimports"
vim.g.go_auto_type_info = 1

-- Function to build Go files
--local function build_go_files()
--  local file = vim.fn.expand('%')
--  if string.match(file, '_test%.go$') then
--    vim.fn['go#test#Test'](0, 1)
--  elseif string.match(file, '%.go$') then
--    vim.fn
--  end
--end

-- Golang Map keys for most used commands
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'go',
  callback = function()
    vim.api.nvim_buf_set_keymap(0, 'n', '<leader>b', ':lua build_go_files()<CR>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 'n', '<leader>r', '<Plug>(go-run)', {})
    vim.api.nvim_buf_set_keymap(0, 'n', '<leader>t', '<Plug>(go-test)', {})
  end,
})

-- Function to check back space
local function check_back_space()
  local col = vim.fn.col('.') - 1
  return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

vim.g.go_template_autocreate = 1
vim.g.go_template_file = "main_tmplt.go"
vim.g.go_template_test_file = "main_tmplt_test.go"

-- Set highlights and tab settings for Go files
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'go',
  callback = function()
    vim.cmd('hi PmenuThumb ctermfg=231 ctermbg=242')
    vim.bo.tabstop = 8
    vim.bo.softtabstop = 0
    vim.bo.expandtab = true
    vim.bo.shiftwidth = 8
    --vim.bo.smarttab = true
  end,
})

-- Debugger windows setup
vim.g.go_debug_windows = {
  vars = 'rightbelow 60vnew',
  stack = 'rightbelow 10new',
}

-- Golang metalinter settings
vim.g.go_metalinter_enabled = { 'vet', 'revive', 'errcheck', 'staticcheck', 'unused' }
vim.g.go_metalinter_command = 'sh -c "GOGC=20 golangci-lint"'
vim.g.go_metalinter_autosave = 0
vim.g.go_metalinter_autosave_enabled = {}
    end
}
