" Vim global plugin for Create ctags
" Last Change: 2018 Mar 29
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
  let g:auto_ctags_tags_args = '--tag-relative=no --recurse=yes --sort=yes'
endif

if !exists("g:auto_ctags_filetype_mode")
  let g:auto_ctags_filetype_mode = 0
endif

if !exists("g:auto_ctags_search_recursively")
  let g:auto_ctags_search_recursively = 0
endif

if !exists("g:auto_ctags_absolute_path")
  let g:auto_ctags_absolute_path = 1
endif

"------------------------
" function
"------------------------
function! auto_ctags#ctags_path()
  let path = ''
  for directory in g:auto_ctags_directory_list
    if g:auto_ctags_search_recursively > 0
      let dirs = finddir(directory, escape(expand('<afile>:p:h'), ' ') . ';', -1)
      if !empty(dirs)
        let directory = dirs[0]
      endif
    endif
    if isdirectory(directory)
      let tags_name = g:auto_ctags_tags_name
      if g:auto_ctags_filetype_mode > 0
        if &filetype !=# ''
          let tags_name = &filetype.'.'.tags_name
        endif
      endif
      let path = directory.'/'.tags_name
      break
    endif
  endfor

  return path
endfunction

function! auto_ctags#ctags_lock_path()
  let path = auto_ctags#ctags_path()
  if len(path) > 0
    let path = path.'.lock'
  endif
  return path
endfunction

function! auto_ctags#ctags_cmd_opt()
  let opt = g:auto_ctags_tags_args
  if g:auto_ctags_filetype_mode > 0
    if &filetype ==# 'cpp'
      let opt = opt.' --languages=c++'
    elseif &filetype !=# ''
      let opt = opt.' --languages='.&filetype
    endif
  endif
  return opt
endfunction

function! auto_ctags#ctags_cmd()
  let l:V = vital#autoctags#new()
  let l:path = l:V.import('System.Filepath')

  let ctags_cmd = ''

  let tags_bin_path = l:path.realpath(g:auto_ctags_bin_path)
  if !executable(tags_bin_path)
    call s:warn('Ctags command not found.')
    return ctags_cmd
  endif

  let currentdir = '.'
  if g:auto_ctags_absolute_path > 0
    let currentdir = getcwd()
  endif

  let tags_path = l:path.realpath(auto_ctags#ctags_path())
  if tags_path == ''
    call s:warn('Tags path not exists.')
    return ctags_cmd
  endif

  let tags_lock_path = l:path.realpath(auto_ctags#ctags_lock_path())
  if glob(tags_lock_path) != ''
    call s:warn('Tags path currently locked.')
    return ctags_cmd
  endif

  let ctags_cmd = tags_bin_path.' '.auto_ctags#ctags_cmd_opt().' -f '.tags_path.' '.currentdir

  return ctags_cmd
endfunction

function! auto_ctags#ctags(recreate)
  if g:auto_ctags ==# 0 && a:recreate ==# 0
    return
  endif

  let cmd = auto_ctags#ctags_cmd()

  if len(cmd) == 0
    return
  endif

  let l:V = vital#autoctags#new()
  let l:file = l:V.import('System.File')
  let l:promise = l:V.import('Async.Promise')
  let l:process = l:V.import('System.Process')
  let l:path = l:V.import('System.Filepath')

  let tags_path = l:path.realpath(auto_ctags#ctags_path())
  let tags_lock_path = l:path.realpath(auto_ctags#ctags_lock_path())

  if a:recreate > 0
    call delete(tags_path)
    call delete(tags_lock_path)
  endif

  if has('job') && has('lambda')
    call writefile([], tags_lock_path)
    call l:promise.new({resolve -> job_start(cmd, {
          \ 'exit_cb': { job, exit_status -> resolve(exit_status) },
          \ })
          \})
          \.catch({ exc -> execute('echomsg string(exc)', '') })
          \.finally({->
          \  delete(tags_lock_path)
          \})

          " debug
          " 'out_cb': { job, msg -> execute('echomsg msg', '') },
          " 'err_cb': { job, msg -> execute('echomsg msg', '') },
          " then({ exit_status -> execute('echomsg "exit: " . exit_status', '') })
  else
    call writefile([], tags_lock_path)
    call l:process.execute(cmd)
    call delete(tags_lock_path)
  endif

  if a:recreate > 0
    redraw!
  endif
endfunction

function! s:warn(msg)
  echohl WarningMsg
  echo 'auto_ctags.vim:' a:msg
  echohl None
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
