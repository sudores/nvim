let orgmode_time_format = '%Y-%M-%d %a %H:%M'
nnoremap \cp "=strftime(orgmode_time_format)<CR>p
nnoremap <F5> "=strftime(orgmode_time_format)<CR>P
inoremap <F5> <C-R>=strftime(orgmode_time_format)<CR>
