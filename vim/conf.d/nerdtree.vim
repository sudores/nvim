" BEGIN NERDTREE    
" Enable nerdtree on startup    
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif    
"autocmd VimEnter * NERDTree | wincmd p    
autocmd StdinReadPre * let s:std_in=1    
"autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | NERDTree | endif    
" map nerdtree hider    
nnoremap <silent> <expr> zq g:NERDTree.IsOpen() ? "\:NERDTreeClose<CR>" : bufexists(expand('%')) ? "\:NERDTreeFind<CR>" : "\:NERDTree<CR>"    
"autocmd BufWinEnter * if getcmdwintype() == '' | silent NERDTreeMirror | endif    
"autocmd StdinReadPre * let s:std_in=1    
"autocmd VimEnter * NERDTree | if argc() > 0 || exists("s:std_in") | wincmd p | endif    
"autocmd BufWinEnter * if getcmdwintype() == '' | silent NERDTreeMirror | endif    
"let NERDTreeMapOpen='<ENTER>'
let NERDTreeMapOpenInTabSilent='<TAB>'
" END NERDTREE    
