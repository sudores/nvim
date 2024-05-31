" BEGIN GOLANG
" Go syntax highlighting
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_operators = 1
" Auto formatting and importing
let g:go_fmt_autosave = 1
let g:go_fmt_command = "goimports"
let g:go_auto_type_info = 1
" Run :GoBuild or :GoTestCompile based on the go file
function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
    call go#test#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunction
" GOLANG Map keys for most used commands.
" Ex: `\b` for building, `\r` for running and `\b` for running test.
autocmd FileType go nmap <leader>b :<C-u>call <SID>build_go_files()<CR>
autocmd FileType go nmap <leader>r  <Plug>(go-run)
autocmd FileType go nmap <leader>t  <Plug>(go-test)
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction
let g:go_template_autocreate=1
let g:go_template_file="main_tmplt.go"
let g:go_template_test_file="main_tmplt_test.go"

autocmd FileType go hi PmenuThumb ctermfg=231 ctermbg=242
autocmd FileType go set tabstop=8 softtabstop=0 expandtab shiftwidth=8 smarttab

" Debugger windows setup
let g:go_debug_windows = {
      \ 'vars':       'rightbelow 60vnew',
      \ 'stack':      'rightbelow 10new',
\ }

let g:go_metalinter_enabled = ['vet','revive','errcheck','staticcheck','unused']
let g:go_metalinter_command = 'sh -c "GOGC=20 golangci-lint"'
let g:go_metalinter_autosave = 0
let g:go_metalinter_autosave_enabled = [] 

" ENG GOLANG
