" Signs color
highlight GitGutterAdd    guifg=#25fa00 ctermfg=46
highlight GitGutterChange guifg=#00e1fa ctermfg=51
highlight GitGutterDelete guifg=#fa0505 ctermfg=9

" Lines background
highlight GitGutterAddLine          guifg=#fa0505 ctermfg=46
highlight GitGutterChangeLine       guifg=#fa0505 ctermfg=51
highlight GitGutterDeleteLine       guifg=#fa0505 ctermfg=9 
highlight GitGutterChangeDeleteLine guifg=#fa0505 ctermfg=51
highlight clear SignColumn

" Change default signs
let g:gitgutter_sign_modified = '*'
let g:gitgutter_sign_modified_removed = '*_'

" Switch to use ripgrep
let g:gitgutter_grep = 'rg'

" Make diff time to appear lower
set updatetime=100

" nmaps
nnoremap ght :GitGutterLineHighlightsToggle<CR>
