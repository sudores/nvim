local opt = vim.opt

-- line numbers setup
opt.relativenumber = true
opt.number = true

-- autoindentantion setup
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true

-- line wrapping
opt.wrap = true
opt.linebreak = true

-- search casing
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- fixind window splitting
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

opt.iskeyword:append("-") -- consider string-string as whole word

-- spelling
opt.spelllang = { "en_us", "en_gb", "ru", "uk" } -- Spelling dictionaries
opt.spell = true

-- redundancy
opt.undofile = true --  keep undo history between sessions
--opt.undodir = "~/.vim/undo/" -- keep undo files out of file dir
--opt.directory = "~/.vim/swp/" -- keep unsaved changes away from file dir
--opt.backupdir = "~/.vim/backup/" -- backups also should not go to git
