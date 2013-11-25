if !exists("g:auto_ctags")
  let g:auto_ctags = 0
endif

command! -nargs=0 Ctags call <SID>ctags('', 1)

function! s:ctags(opt, redraw)
  let cmd = 'ctags -R '.a:opt.' 2>/dev/null'
  silent! execute '!'.cmd.' &'

  if a:redraw > 0
    redraw!
  endif
endfunction

if g:auto_ctags > 0
  augroup auto_ctags
    autocmd!
    autocmd BufWritePost * call <SID>ctags('-a', 0)
  augroup END
endif
