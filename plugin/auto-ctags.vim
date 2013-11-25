" Vim global plugin for Create ctags
" Last Change: 2013 Nov 26
" Maintainer: Yudai Tsuyuzaki <soramugi.chika@gmail.com>
" License: This file is placed in the public domain.

if exists("g:loaded_auto_ctags")
  finish
endif
let g:loaded_auto_ctags = 1

let s:save_cpo = &cpo
set cpo&vim

if !exists("g:auto_ctags")
  let g:auto_ctags = 0
endif

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

if !exists(":Ctags")
  command -nargs=0 Ctags call <SID>ctags('', 1)
endif

let &cpo = s:save_cpo
unlet s:save_cpo
