vim.g.mapleader = '\\'
-- System buffer copy
vim.keymap.set("v", "<Leader>y", '"+y')
vim.keymap.set("n",  '<Leader>Y', '"+Y')
vim.keymap.set("n",  '<Leader>y', '"+y')
vim.keymap.set("n",  '<Leader>yy', '"+yy')

vim.keymap.set("v",  '<Leader>d', '"+d')
vim.keymap.set("n",  '<Leader>D', '"+D')
vim.keymap.set("n",  '<Leader>d', '"+d')
vim.keymap.set("n",  '<Leader>dd', '"+dd')

vim.keymap.set("n", '<Leader>p', '"+p')
vim.keymap.set("n", '<Leader>P', '"+P')
vim.keymap.set("v", '<Leader>p', '"+p')
vim.keymap.set("v", '<Leader>P', '"+P')

vim.api.nvim_set_keymap('n', '<Leader>ta', ':tabnew<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>tn', ':tabnext<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>tm', ':tabmove ', { noremap = true, silent = true }) -- Notice the space after tabmove
vim.api.nvim_set_keymap('n', '<Leader>tc', ':tabclose<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>to', ':tabonly<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>tp', ':tabprevious<CR>', { noremap = true, silent = true })

-- BUFFERS
vim.api.nvim_set_keymap('n', 'ta', ':enew<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'tn', ':bnext<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'tp', ':bprevious<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'tc', ':bdelete<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'tC', ':bdelete!<CR>', { noremap = true, silent = true })

-- Plugins keymaps
vim.keymap.set("n", "<Leader>fb", ":Telescope file_browser<CR>")

-- LSP Keymaps
vim.api.nvim_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { noremap = true, silent = true })



-- Insert current date where cursor is
function insert_date_at_cursor()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local current_line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
  local date_str = vim.fn.strftime("%Y-%m-%d")
  local new_line = current_line:sub(1, col) .. date_str .. current_line:sub(col)
  vim.api.nvim_buf_set_lines(0, row - 1, row, false, {new_line})
  vim.api.nvim_win_set_cursor(0, {row, col + #date_str})
end
vim.api.nvim_create_user_command('InsertDateAtCursor', insert_date_at_cursor, {})
vim.api.nvim_set_keymap("n", "gi", ":InsertDateAtCursor<CR>", { noremap = true, silent = true })
