function! s:ctags()
  silent! execute '!ctags -R . &'
endfunction

augroup auto-ctags
    au BufWritePost * call s:ctags()
augroup END
