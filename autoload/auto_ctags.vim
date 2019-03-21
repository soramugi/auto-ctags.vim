" Vim global plugin for Create ctags
" Last Change: 4 Jun 2018
" Maintainer: Yudai Tsuyuzaki <soramugi.chika@gmail.com>
" License: This file is placed in the public domain.

if exists("g:autoloaded_auto_ctags")
  finish
endif
let g:autoloaded_auto_ctags = 1

let s:save_cpo = &cpo
set cpo&vim

let s:File = vital#autoctags#import('System.File')
let s:Process = vital#autoctags#import('System.Process')
let s:Path = vital#autoctags#import('System.Filepath')
let s:Job = vital#autoctags#import('System.Job')
let s:Promise = vital#autoctags#import('Async.Promise')
let s:Set = vital#autoctags#import('Data.Set')

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
  let g:auto_ctags_tags_args = ['--tag-relative=yes', '--recurse=yes', '--sort=yes']
elseif type(g:auto_ctags_tags_args) == type('')
  let g:auto_ctags_tags_args = split(g:auto_ctags_tags_args, ' ')
endif

if !exists("g:auto_ctags_filetype_mode")
  let g:auto_ctags_filetype_mode = 0
endif

if !exists("g:auto_ctags_search_recursively")
  let g:auto_ctags_search_recursively = 0
endif

if !exists("g:auto_ctags_absolute_path")
  let g:auto_ctags_absolute_path = 0
endif

" lockfile set
let s:lockfiles = s:Set.set()

"------------------------
" function
"------------------------
function! auto_ctags#ctags_path()
  let path = ''
  for directory in g:auto_ctags_directory_list
    if g:auto_ctags_search_recursively > 0
      let dirs = finddir(directory, escape(expand('<afile>:p:h'), ' ') . ';', -1)
      if !empty(dirs)
        let directory = fnamemodify(dirs[0], ':p')
      endif
    endif
    if isdirectory(directory)
      let tags_name = g:auto_ctags_tags_name
      if g:auto_ctags_filetype_mode > 0
        if &filetype !=# ''
          let tags_name = &filetype.'.'.tags_name
        endif
      endif
      let path = directory . s:Path.separator() . tags_name
      break
    endif
  endfor

  return s:Path.realpath(path)
endfunction

function! auto_ctags#ctags_lock_path()
  let path = auto_ctags#ctags_path()

  if len(path) > 0
    let path = path . '.lock'
  endif

  return s:Path.realpath(path)
endfunction

function! auto_ctags#ctags_cmd_opt()
  let opt = g:auto_ctags_tags_args
  if g:auto_ctags_filetype_mode > 0
    if &filetype ==# 'cpp'
      let opt = opt + ['--languages=c++']
    elseif &filetype !=# ''
      let opt = opt + ['--languages='.&filetype]
    endif
  endif
  return opt
endfunction

function! auto_ctags#ctags_cmd()
  let ctags_cmd = []

  let tags_bin_path = s:Path.realpath(g:auto_ctags_bin_path)
  if !executable(tags_bin_path)
    call s:warn('Ctags command not found.')
    return ctags_cmd
  endif

  let currentdir = '.'
  if g:auto_ctags_absolute_path > 0
    " Windows ctags command get currentdir for backslash path with slash aware
    " shell (ex bash)
    "  > c:/home> ctasg -f .git/tags 'c:\home'
    " shellslash no affect in *nix
    if exists('+shellslash')
      let saved_shellslash = &shellslash
      set noshellslash
    endif
    let currentdir = getcwd()
    if exists('+shellslash')
      let &shellslash = saved_shellslash
    endif
  endif

  let tags_path = auto_ctags#ctags_path()
  if tags_path == ''
    call s:warn('Tags path not exists.')
    return ctags_cmd
  endif

  let tags_lock_path = auto_ctags#ctags_lock_path()
  if glob(tags_lock_path) != ''
    call s:warn('Tags path currently locked.')
    return ctags_cmd
  endif

  let ctags_cmd = [tags_bin_path] + auto_ctags#ctags_cmd_opt() + ['-f', tags_path, currentdir]

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

  let tags_path = auto_ctags#ctags_path()
  let tags_lock_path = auto_ctags#ctags_lock_path()

  if a:recreate > 0
    call delete(tags_path)
    call delete(tags_lock_path)
  endif

  if s:Promise.is_available() && s:Job.is_available()
    call s:lockfile_add_touch(tags_lock_path)
    call s:Promise.new({resolve -> s:Job.start(cmd, {
            \ 'stdout': [''],
            \ 'stderr': [''],
            \ 'on_exit':{ exit_status -> resolve(exit_status) },
          \ })
          \})
          \.catch({ exc -> execute('echomsg string(exc)', '') })
          \.finally(funcref("s:lockfile_del_remove", [tags_lock_path]))
  else
    call s:lockfile_add_touch(tags_lock_path)
    call s:Process.execute(cmd)
    call s:lockfile_del_remove(tags_lock_path)
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


" after care:lockfile delete at vim exit
function! s:lockfile_del_atquit()
  let filelist = s:lockfiles.to_list()
  for file in filelist
    if filereadable(file)
      call s:lockfile_del_remove(file)
    endif
  endfor
endfunction

function! s:lockfile_add_touch(path)
  call s:lockfiles.add(a:path)
  call writefile([], a:path)
endfunction

function! s:lockfile_del_remove(path)
  call delete(a:path)
  call s:lockfiles.remove(a:path)
endfunction

augroup autoctags_exit
    autocmd!
    autocmd VimLeave * call <SID>lockfile_del_atquit()
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
