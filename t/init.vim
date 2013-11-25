filetype plugin on
runtime! plugin/*.vim

describe 'init default'
  before
    new
  end

  after
    close!
  end

  it 'auto_ctags == 0'
    Expect g:auto_ctags == 0
  end
end

describe 'init auto mode'
  before
    let g:auto_ctags = 1
    new
  end

  after
    close!
  end

  it 'auto_ctags == 1'
    Expect g:auto_ctags == 1
  end

  it 'augroup auto_ctags'
    ""autocmd auto_ctags
  end
end
