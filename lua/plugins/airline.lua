vim.cmd("let g:airline_theme='powerlineish'")
vim.cmd("let g:airline#extensions#tabline#enabled = '1'")
vim.cmd("let g:airline#extensions#tabline#left_sep = ' '")
vim.cmd("let g:airline#extensions#tabline#left_alt_sep = '|'")
vim.cmd("let g:airline_detect_spell=0")

return {
    'vim-airline/vim-airline', 
    lazy = false,
    priority = 1000,
    dependencies = {
        'vim-airline/vim-airline-themes',
        "ryanoasis/vim-devicons",
    }
}
