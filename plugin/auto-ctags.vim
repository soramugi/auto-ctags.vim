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

if !exists("g:auto_ctags_tags_args")
  let g:auto_ctags_tags_args = '--tag-relative --recurse --sort=yes'
endif

if !exists("g:auto_ctags_filetype_mode")
  let g:auto_ctags_filetype_mode = 0
endif

function! s:get_ctags_path()
  let s:path = ''
  for s:directory in g:auto_ctags_directory_list
    if isdirectory(s:directory)
      let s:tags_name = g:auto_ctags_tags_name
      if g:auto_ctags_filetype_mode > 0
        if &filetype !=# ''
          let s:tags_name = &filetype.'.'.s:tags_name
        endif
      endif
      let s:path = s:directory.'/'.s:tags_name
      break
    endif
  endfor

  return s:path
endfunction

function! s:get_ctags_lock_path()
  let s:path = s:get_ctags_path()
  if len(s:path) > 0
    let s:path = s:path.'.lock'
  endif
  return s:path
endfunction

function! s:get_ctags_cmd_opt()
  let s:opt = g:auto_ctags_tags_args
  if g:auto_ctags_filetype_mode > 0
      if &filetype !=# ''
        let s:opt = s:opt.' --languages='.&filetype
      endif
  endif
  return s:opt
endfunction

function! s:get_ctags_cmd()
  let s:ctags_cmd = ''

  let s:tags_path = s:get_ctags_path()
  let s:tags_lock_name = s:get_ctags_lock_path()
  if len(s:tags_path) > 0 && glob(s:tags_lock_name) == ''
    let s:ctags_cmd = 'touch '.s:tags_lock_name.' && '
          \.'ctags '.s:get_ctags_cmd_opt().' -f '.s:tags_path.' && '
          \.'rm '.s:tags_lock_name
  endif

  return s:ctags_cmd
endfunction

function! s:ctags(recreate)
  if g:auto_ctags ==# 0 && a:recreate ==# 0
    finish
  endif
  if a:recreate > 0
    silent! execute '!rm '.s:get_ctags_path().' 2>/dev/null'
    silent! execute '!rm '.s:get_ctags_lock_path().' 2>/dev/null'
  endif

  let s:cmd = s:get_ctags_cmd()
  if len(s:cmd) > 0
    silent! execute '!sh -c "'.s:cmd.'" 2>/dev/null &'
  endif

  if a:recreate > 0
    redraw!
  endif
endfunction

augroup auto_ctags
  autocmd!
  autocmd BufWritePost * call <SID>ctags(0)
augroup END

if !exists(":Ctags")
  command -nargs=0 Ctags call <SID>ctags(1)
endif

let &cpo = s:save_cpo
unlet s:save_cpo
