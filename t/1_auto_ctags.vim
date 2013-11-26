let g:auto_ctags = 1

runtime! plugin/*.vim

describe 'init auto mode'
  before
    new
  end

  after
    !rm tags
    close!
  end

  it 'auto_ctags == 1'
    Expect g:auto_ctags == 1
  end

  ""it 'write'
  ""  write
  ""  Expect system('ls tags') == "tags\n"
  ""end
end
