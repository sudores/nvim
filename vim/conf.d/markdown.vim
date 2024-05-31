" BEGIN MARKDOWN    
" disable md folding    
let g:vim_markdown_folding_disabled=1    
set nofoldenable    
" Markdown preview setting    
let vim_markdown_preview_github=1    
let g:markdown_enable_folding = 0    
let g:vim_markdown_fenced_languages = ['csharp=cs', 'bash=sh', 'c=c', 'go=go', "python=python" ]    

if &ft=='markdown'
    set colorcolumn=80
endif
" END MARKDOWN    
