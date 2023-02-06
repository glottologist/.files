
" ripgrep smartcase (search with case insensitive)
let g:rg_command = 'rg --vimgrep -S'

" search work under cursor with CtrlSF (it uses ripgrep as the engine)
nnoremap <leader>fr              <cmd>CtrlSFWordPath<CR>

" open quickfix windows when running AsyncRun
let g:asyncrun_open = 8

" airline: status bar at the bottom
let g:airline_powerline_fonts=1

let g:airline_section_error = '%{airline#util#wrap(airline#extensions#coc#get_error(),0)}'
let g:airline_section_warning = '%{airline#util#wrap(airline#extensions#coc#get_warning(),0)}'

" Highlighting for jsonc filetype
autocmd FileType json syntax match Comment +\/\/.\+$+

" EasyMotion search with highlighting
map  / <Plug>(easymotion-sn)
omap / <Plug>(easymotion-tn)

" Hoogle config
let g:hoogle_search_count = 20
au BufNewFile,BufRead *.hs map <silent> <F1> :Hoogle<CR>
au BufNewFile,BufRead *.hs map <silent> <C-c> :HoogleClose<CR>

" Nerdtree
map <C-F> :NERDTreeToggle<CR>
map <C-S> :NERDTreeFind<CR>

let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'

let g:NERDTreeMinimalUI = 1
let g:NERDTreeDirArrows = 1
let g:NERDTreeShowHidden=1


" Nerd commenter
filetype plugin on

" Nerdtree git plugin symbols
let g:NERDTreeGitStatusIndicatorMapCustom = {
    \ "Modified"  : "ᵐ",
    \ "Staged"    : "ˢ",
    \ "Untracked" : "ᵘ",
    \ "Renamed"   : "ʳ",
    \ "Unmerged"  : "ᶴ",
    \ "Deleted"   : "ˣ",
    \ "Dirty"     : "˜",
    \ "Clean"     : "ᵅ",
    \ "Unknown"   : "?"
    \ }


" NerdTree automatically open
autocmd StdinReadPre * let s:std_in=1
autocmd VImEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" NerdTree automatically close
"let g:NERDTreeQuitOnOpen = 1
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
" Exit Vim if NERDTree is the only window left.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() |
    \ quit | endif
" NerdTree Deleting Files
let g:NERDTreeAutoDeleteBuffer = 1

"" Telescope
"" Find files using Telescope command-line sugar.
"nnoremap <leader>ff <cmd>Telescope find_files<cr>
"nnoremap <leader>fg <cmd>Telescope live_grep<cr>
"nnoremap <leader>fb <cmd>Telescope buffers<cr>
"nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" coc-fzf
" allow to scroll in the preview
set mouse=a
" mappings
nnoremap <leader>fl              <cmd>CocFzfList<CR>
nnoremap <leader>fa              <cmd>CocFzfList diagnostics<CR>
nnoremap <leader>fc              <cmd>CocFzfList commands<CR>
nnoremap <leader>fe              <cmd>CocFzfList extensions<CR>
nnoremap <leader>fo              <cmd>CocFzfList outline<CR>
nnoremap <leader>fp              <cmd>CocFzfListResume<CR>
nnoremap <leader>fs              <cmd>CocFzfList symbols<CR>
nnoremap <leader>ft              <cmd>CocFzfList location<CR>


" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" Fuzzy finder shortcut
nnoremap <leader>ff <cmd>FZF<cr>
"nnoremap <C-p> :FZF<CR>

 command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)

 command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

" vim-scala
au BufRead,BufNewFile *.sbt set filetype=scala

let g:lightline = { 'colorscheme': 'PaperColor' }

let g:calendar_google_calendar = 1
let g:calendar_google_task = 1

" Use silver-sercher for word find
let g:ackprg = 'ag --nogroup --nocolor --column'
