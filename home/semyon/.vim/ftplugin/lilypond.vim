:syntax match Comment +\(%\)\@<!%[^%].*+

:nnoremap <buffer> <localleader>b :!lilypond %<CR>
:nnoremap <buffer> <localleader>p :!mupdf %:r.pdf &<CR>
