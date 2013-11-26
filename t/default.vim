runtime! plugin/*.vim

describe 'init default'
  before
    new
  end

  after
    !rm tags
    close!
  end

  it 'auto_ctags == 0'
    Expect g:auto_ctags == 0
  end

  it ':Ctags'
    Ctags
    Expect system('ls tags') == "tags\n"
  end
end
