" 1. Install vim-plug
" curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
" 2. Install plugins
" :PlugInstall
call plug#begin('~/.vim/plugged')

" Support for opening the files at specified:line
Plug 'bogado/file-line'

Plug 'godlygeek/tabular'

Plug 'tpope/vim-fugitive'
map <silent> <leader>gb :Git blame<CR>
map <silent> <leader>gd :Gvdiff HEAD<CR>

Plug 'scrooloose/nerdtree'
map <silent> <leader>t :NERDTreeFind<CR>
let NERDTreeIgnore=['^target$[[dir]]']
let g:NERDTreeQuitOnOpen = 1

" Scala
Plug 'derekwyatt/vim-scala'
au BufRead,BufNewFile *.sbt set filetype=scala

" coc.nvim
Plug 'neoclide/coc.nvim', {'branch': 'release'}
source ~/.vim/coc-nvim-mappings.vim

Plug 'nathanaelkane/vim-indent-guides'
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_auto_colors = 0
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1
hi IndentGuidesOdd  ctermbg=234
hi IndentGuidesEven ctermbg=233

call plug#end()
