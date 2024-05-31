" BEGIN COC
inoremap <silent><expr> <Tab>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<Tab>" :
      \ coc#refresh()
inoremap <silent><expr> <c-space> coc#refresh()
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
let g:coc_snippet_next = '<TAB>'

inoremap <silent><expr> <Tab>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()

inoremap <expr> <Tab> coc#pum#visible() ? coc#pum#next(1) : "\<Tab>"
inoremap <expr> <S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<S-Tab>"

" spell check comfig
vmap <leader>a <Plug>(coc-codeaction-selected)
nmap <leader>a <Plug>(coc-codeaction-selected)

" trigger completion
inoremap <silent><expr> <C-f> coc#pum#visible() ? coc#pum#confirm() : "\<C-f>"

" cancel completion
inoremap <silent><expr> <C-e> coc#pum#visible() ? coc#pum#cancel() : "\<C-e>"

" Use <C-l> for trigger snippet expand.
imap <C-l> <Plug>(coc-snippets-expand)
" Use <C-j> for select text for visual placeholder of snippet.
vmap <C-j> <Plug>(coc-snippets-select)
" Use <C-j> for jump to next placeholder, it's default of coc.nvim
let g:coc_snippet_next = '<c-j>'
" Use <C-k> for jump to previous placeholder, it's default of coc.nvim
let g:coc_snippet_prev = '<c-k>'
" Use <C-j> for both expand and jump (make expand higher priority.)
imap <C-j> <Plug>(coc-snippets-expand-jump)
" Use <leader>x for convert visual selected code to snippet
xmap <leader>x  <Plug>(coc-convert-snippet)

" changing error message color
hi! CocErrorLine    ctermbg=238
hi! CocInfoSign     ctermfg=45
hi! CocErrorFloat   ctermfg=255 ctermbg=255
hi! CocHintFloat    ctermfg=255 ctermbg=255
"hi! CocFloatThumb   ctermfg=255 ctermbg=255
"hi! CocFloatSbar    ctermfg=255 ctermbg=255
hi! CocFloatActive  ctermfg=255 
"ctermbg=255
hi! CocErrorSign    ctermfg=255 ctermbg=196
hi! CocInfoFloat    ctermfg=255 ctermbg=255
"hi! CocWarningFloat ctermfg=255 ctermbg=255
"hi! CocInfoFloat    ctermfg=255 ctermbg=255
"hi! CocHintFloat    ctermfg=255 ctermbg=255
"hi! CocWarningFloat ctermfg=255 ctermbg=102
" cocswagger 
command -nargs=0 Swagger :CocCommand swagger.render

" disable json quotes hidding
let g:indentLine_conceallevel = 0
" END COC
