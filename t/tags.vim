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
    Expect filereadable('tags') == 1
  end
end
