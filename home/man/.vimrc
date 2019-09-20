" 1. Install vim-plug
" curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
" 2. Install plugins
" :PlugInstall
call plug#begin('~/.vim/plugged')

Plug 'godlygeek/tabular'

Plug 'scrooloose/nerdtree'
map <leader>t :NERDTreeFind<CR>
let NERDTreeIgnore=['^target$[[dir]]']

" Scala
Plug 'derekwyatt/vim-scala'
au BufRead,BufNewFile *.sbt set filetype=scala

" coc.nvim
Plug 'neoclide/coc.nvim', {'branch': 'release'}

set updatetime=300
set nobackup nowritebackup
" Trigger completion
inoremap <silent><expr> <c-space> coc#refresh()
" Confirm completion
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" Navigate diagnostics
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)
" Goto's
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
" Show documentation
nnoremap <silent> <C-q> :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if &filetype == 'vim'
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction
" Highlight symbol
autocmd CursorHold * silent call CocActionAsync('highlight')
" Rename current word
nmap <leader>rn <Plug>(coc-rename)
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Search CWD files
nnoremap <silent> <space>f  :<C-u>CocList files<cr>
" Search MRU (most recently used) files
nnoremap <silent> <space>r  :<C-u>CocList mru<cr>
" Grep workspace
nnoremap <silent> <space>g  :<C-u>CocList grep<cr>
cabbrev gr <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'CocList<space>grep' : 'gr')<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>
" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
inoremap <silent><expr> <TAB>
\ pumvisible() ? "\<C-n>" :
\ <SID>check_back_space() ? "\<TAB>" :
\ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

call plug#end()
