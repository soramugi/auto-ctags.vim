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

if !exists("g:auto_ctags_directory_list")
  let g:auto_ctags_directory_list = ['.']
endif

if !exists("g:auto_ctags_tags_name")
  let g:auto_ctags_tags_name = 'tags'
endif

let s:ctags_cmd = 'ctags'
let s:ctags_opt = '--tag-relative'
let s:ctags_create = 0
for s:directory in g:auto_ctags_directory_list
  if isdirectory(s:directory)
    let s:tags_name = s:directory.'/'.g:auto_ctags_tags_name
    ""silent! execute 'set tags+='.s:tags_name
    let s:ctags_opt = s:ctags_opt.' -f '.s:tags_name
    let s:ctags_create = 1
  endif
  if s:ctags_create > 0
    break
  endif
endfor

function! s:ctags(opt, redraw)

  if s:ctags_create > 0
    silent! execute '!'.s:ctags_cmd.' '.s:ctags_opt.' '.a:opt.' 2>/dev/null &'
  endif

  if a:redraw > 0
    redraw!
  endif
endfunction

function! s:ctags_delete()
  silent! execute '!rm '.s:tags_name.' 2>/dev/null'
  redraw!
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

if !exists(":CtagsDelete")
  command -nargs=0 CtagsDelete call <SID>ctags_delete()
endif

let &cpo = s:save_cpo
unlet s:save_cpo
