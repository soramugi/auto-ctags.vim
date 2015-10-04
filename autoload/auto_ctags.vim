" Vim global plugin for Create ctags
" Last Change: 2013 Dec 17
" Maintainer: Yudai Tsuyuzaki <soramugi.chika@gmail.com>
" License: This file is placed in the public domain.

if exists("g:autoloaded_auto_ctags")
  finish
endif
let g:autoloaded_auto_ctags = 1

let s:save_cpo = &cpo
set cpo&vim

"------------------------
" setting
"------------------------
if !exists("g:auto_ctags")
  let g:auto_ctags = 0
endif

if !exists("g:auto_ctags_directory_list")
  let g:auto_ctags_directory_list = ['.']
endif

if !exists("g:auto_ctags_tags_name")
  let g:auto_ctags_tags_name = 'tags'
endif

if !exists("g:auto_ctags_bin_path")
  let g:auto_ctags_bin_path = 'ctags'
endif

if !exists("g:auto_ctags_tags_args")
  let g:auto_ctags_tags_args = '--tag-relative --recurse --sort=yes'
endif

if !exists("g:auto_ctags_filetype_mode")
  let g:auto_ctags_filetype_mode = 0
endif

"------------------------
" function
"------------------------
function! auto_ctags#ctags_path()
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

function! auto_ctags#ctags_lock_path()
  let s:path = auto_ctags#ctags_path()
  if len(s:path) > 0
    let s:path = s:path.'.lock'
  endif
  return s:path
endfunction

function! auto_ctags#ctags_cmd_opt()
  let s:opt = g:auto_ctags_tags_args
  if g:auto_ctags_filetype_mode > 0
      if &filetype ==# 'cpp'
        let s:opt = s:opt.' --languages=c++'
      elseif &filetype !=# ''
        let s:opt = s:opt.' --languages='.&filetype
      endif
  endif
  return s:opt
endfunction

function! auto_ctags#ctags_cmd()
  let s:ctags_cmd = ''
  let s:tags_bin_path = g:auto_ctags_bin_path

  let s:tags_path = auto_ctags#ctags_path()
  let s:tags_lock_name = auto_ctags#ctags_lock_path()
  if len(s:tags_path) > 0 && glob(s:tags_lock_name) == ''
    let s:ctags_cmd = 'touch '.s:tags_lock_name.' && '
          \.s:tags_bin_path.' '.auto_ctags#ctags_cmd_opt().' -f '.s:tags_path.' && '
          \.'rm '.s:tags_lock_name
  endif

  return s:ctags_cmd
endfunction

function! auto_ctags#ctags(recreate)
  if g:auto_ctags ==# 0 && a:recreate ==# 0
    return
  endif
  if a:recreate > 0
    silent! execute '!rm '.auto_ctags#ctags_path().' 2>/dev/null'
    silent! execute '!rm '.auto_ctags#ctags_lock_path().' 2>/dev/null'
  endif

  let s:cmd = auto_ctags#ctags_cmd()
  if len(s:cmd) > 0
    silent! execute '!sh -c "'.s:cmd.'" 2>/dev/null &'
  endif

  if a:recreate > 0
    redraw!
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
