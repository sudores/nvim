local opt = vim.opt

local completionBoxColor={bg='#000000', fg='#ffffff'}
local completionBoxCursorColor={bg='#262626'}
-- cursor line
vim.cmd("colorscheme vim")
opt.cursorline = true -- highlight the current cursor line
vim.api.nvim_set_hl(0, 'CursorLine', {underline = false, bg='NONE'})

-- Disable the background color
vim.api.nvim_set_hl(0, 'Normal', {bg='NONE'})

-- setting colors
opt.termguicolors = true
opt.signcolumn = "yes" -- show sign column so that text doesn't shift
vim.api.nvim_set_hl(0, 'SignColumn', {bg='none'})

-- Setting the right colors for the completion box
vim.api.nvim_set_hl(0, 'CmpNormal',     completionBoxColor)
vim.api.nvim_set_hl(0, 'CmpCursorLine', completionBoxCursorColor)

-- Setting colors for nvim commands completion box
vim.api.nvim_set_hl(0, 'Pmenu',      completionBoxColor)
vim.api.nvim_set_hl(0, 'PmenuThumb', completionBoxCursorColor)
