function! s:ctags()
  silent! execute '!ctags -R . 2>&1 /dev/null &'
endfunction

augroup auto-ctags
    au BufWritePost * call s:ctags()
augroup END
