" Set 'background' back to the default.  The value can't always be estimated
" and is then guessed.
hi clear Normal
set bg&

" Remove all existing highlighting and set the defaults.
hi clear

" Load the syntax highlighting defaults, if it's enabled.
if exists("syntax_on")
  syntax reset
endif

let colors_name = "myown"

" 0 8  black
" 1 9  red
" 2 10 green
" 3 11 yellow
" 4 12 blue
" 5 13 magenta
" 6 14 cyan
" 7 15 white

" Disable bold style
set t_md=

"hi Visual cterm=none ctermfg=0 ctermbg=11
hi Visual cterm=none ctermfg=black ctermbg=yellow
hi MatchParen ctermfg=0 ctermbg=3
hi Error ctermfg=0 ctermbg=1
hi NonText ctermfg=8
hi ModeMsg ctermfg=16 ctermbg=11
hi Comment ctermfg=7
hi Folded ctermfg=8 ctermbg=0

hi Search cterm=none ctermfg=0 ctermbg=3
hi clear IncSearch
hi link IncSearch Search

hi StatusLine cterm=none ctermfg=0 ctermbg=11
hi StatusLineNC cterm=none ctermfg=0 ctermbg=8
set fillchars+=vert:\ 
hi clear VertSplit
hi link VertSplit StatusLineNC

set cursorline
hi LineNr ctermfg=8 ctermbg=0
hi CursorLine cterm=none
hi CursorLineNr cterm=none ctermfg=11 ctermbg=0

hi DiffAdd cterm=none ctermfg=0 ctermbg=2
hi DiffDelete cterm=none ctermfg=0 ctermbg=8
hi DiffChange cterm=none ctermfg=0 ctermbg=1
hi DiffText cterm=none ctermfg=0 ctermbg=9
hi diffFile ctermfg=7 ctermbg=11
hi clear diffIndexLine
hi link diffIndexLine diffFile

" vim: sw=2
