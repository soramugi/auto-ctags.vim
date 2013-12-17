" Vim global plugin for Create ctags
" Last Change: 2013 Dec 17
" Maintainer: Yudai Tsuyuzaki <soramugi.chika@gmail.com>
" License: This file is placed in the public domain.

if exists("g:loaded_auto_ctags")
  finish
endif
let g:loaded_auto_ctags = 1

let s:save_cpo = &cpo
set cpo&vim

augroup auto_ctags
  autocmd!
  autocmd BufWritePost * call auto_ctags#ctags(0)
augroup END

command! Ctags call auto_ctags#ctags(1)

let &cpo = s:save_cpo
unlet s:save_cpo
