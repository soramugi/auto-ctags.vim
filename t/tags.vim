runtime! plugin/*.vim

describe 'create tags'
  before
    new
  end

  after
    !rm tags
    close!
  end

  it ':Ctags'
    Ctags
    Expect system('ls tags') == "tags\n"
  end
end

""describe 'create tags auto mode'
""  before
""    let g:auto_ctags = 1
""    new
""  end
""
""  after
""    !rm tags
""    close!
""  end
""
""  it 'write'
""    write
""    Expect filereadable('tags') == 1
""  end
""end
