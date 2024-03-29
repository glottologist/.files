filetype off

" Leader & Shell
let mapleader=' '
set shell=/home/jason/.nix-profile/bin/fish

" Better Unix support
set viewoptions=folds,options,cursor,unix,slash
set encoding=utf-8

" Relative numbers
set relativenumber

" Handle window actions with Meta instead of <C-w>
" Switching
nnoremap <M-h> <C-w>h
nnoremap <M-j> <C-w>j
nnoremap <M-k> <C-w>k
nnoremap <M-l> <C-w>l

" Moving
nnoremap <M-H> <C-w>H
nnoremap <M-J> <C-w>J
nnoremap <M-K> <C-w>K
nnoremap <M-L> <C-w>L
nnoremap <M-x> <C-w>x

" Resizing
nnoremap <M-=> <C-w>=
nnoremap <M-+> <C-w>+
nnoremap <M--> <C-w>-
nnoremap <M-<> <C-w><
nnoremap <M->> <C-w>>

" Buffer Movement
nnoremap <M-[> :bprevious<CR>
nnoremap <M-]> :bnext<CR>
nnoremap <M-b> :ls<CR>
nnoremap <M-c> :%bd


" True color support
set termguicolors

" Theme
set background=light
colorscheme PaperColor

" Other options
syntax on
set backspace=2
set laststatus=2
set noshowmode

" Tabs as spaces
set expandtab     " Tab transformed in spaces
set tabstop=2     " Sets tab character to correspond to x columns.
                  " x spaces are automatically converted to <tab>.
                  " If expandtab option is on each <tab> character is converted to x spaces.
set softtabstop=2 " column offset when PRESSING the tab key or the backspace key.
set shiftwidth=2  " column offset when using keys '>' and '<' in normal mode.

" Non-mapped function for tab toggles
function! TabToggle()
  if &expandtab
    set noexpandtab
  else
    set expandtab
  endif
endfunc

" Clear search highlighting
nnoremap <C-z> :nohlsearch<CR>

" Terminal mode exit shortcut
:tnoremap <Esc> <C-\><C-n>

" Fixes broken cursor on Linux
set guicursor=

" Trim whitespace function
function! TrimWhitespace()
    let l:save_cursor = getpos('.')
    %s/\s\+$//e
    call setpos('.', l:save_cursor)
endfun

command! TrimWhitespace call TrimWhitespace() " Trim whitespace with command
autocmd BufWritePre * :call TrimWhitespace()  " Trim whitespace on every save

" General editor options
set hidden                  " Hide files when leaving them.
set number                  " Show line numbers.
set numberwidth=4           " Minimum line number column width.
set cmdheight=2             " Number of screen lines to use for the commandline.
set textwidth=0             " Lines length limit (0 if no limit).
set formatoptions=jtcrq     " Sensible default line auto cutting and formatting.
set linebreak               " Don't cut lines in the middle of a word .
set showmatch               " Shows matching parenthesis.
set matchtime=2             " Time during which the matching parenthesis is shown.
set listchars=tab:▸\ ,eol:¬ " Invisible characters representation when :set list.

set clipboard=unnamedplus   " Copy/Paste to/from clipboard
set cursorline              " Highlight the line cursor is currently on
set cursorcolumn            " Highlight the column the cursor is currently on"
set completeopt+=noinsert   " Select the first item of popup menu automatically without inserting it

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300
" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Search
set incsearch  " Incremental search.
set ignorecase " Case insensitive.
set smartcase  " Case insensitive if no uppercase letter in pattern, case sensitive otherwise.
set nowrapscan " Don't go back to first match after the last match is found.

" Auto-commands Vimscript
augroup vimscript_augroup
  autocmd!
  autocmd FileType vim nnoremap <buffer> <M-z> :execute "help" expand("<cword>")<CR>
augroup END

" Spell check for markdown files
au BufNewFile,BufRead *.md set spell

" Disable the annoying and useless ex-mode
nnoremap Q <Nop>
nnoremap gQ <Nop>


" close quickfix window
nnoremap <Esc> :cclose<CR>

" Clear search highlighting
nnoremap <C-z> :nohlsearch<CR>

" Terminal mode exit shortcut
:tnoremap <Esc> <C-\><C-n>

" Incremental substitution
set inccommand=split

" Disable background (let picom manage it)
hi Normal guibg=NONE ctermbg=NONE
