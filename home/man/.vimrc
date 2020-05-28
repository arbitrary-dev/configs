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
source ~/.vim/coc-nvim-mappings.vim

" CoffeeScript
Plug 'kchmck/vim-coffee-script'

call plug#end()
