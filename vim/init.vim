set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath
for f in split(glob('~/.config/nvim/conf.d/*.vim'), '\n')
    exe 'source' f
endfor
