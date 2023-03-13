
" Gist
" Post current buffer to gist
nnoremap <leader>ig :Gist<cr>
" Create a private gist
nnoremap <leader>ip :Gist -p<cr>
" Create a public Gist
nnoremap <leader>iu :Gist -P<cr>
" Create an anonymous gist
nnoremap <leader>ia :Gist -a<cr>
" Create a gist with all open buffers
nnoremap <leader>ib :Gist -m<cr>
" Edit gist
nnoremap <leader>ie :Gist -e<cr>
" Delete gist
nnoremap <leader>id :Gist -d<cr>

" Git
" Git add
nnoremap <leader>ga  :Git add<cr>
" Commit browser
nnoremap <leader>gb  :GV<cr>
" Commit browser current file
nnoremap <leader>gbc  :GV!<cr>
" Git commit
nnoremap <leader>gc  :Git commit<cr>
" Git diff
nnoremap <leader>gd  :Git diff<cr>
" Git difftool
nnoremap <leader>gdt :Git difftool<cr>
" Git merge
nnoremap <leader>gm  :Git merge<cr>
" Git mergetool
nnoremap <leader>gmt  :Git mergetool<cr>
