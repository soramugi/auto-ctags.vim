require 'spec_helper'

def type(string)
  string.scan(/<.*?>|./).each do |key|
    if /<.*>/.match(key)
      vim.feedkeys "\\#{key}"
    else
      vim.feedkeys key
    end
  end
end

describe "Auto Ctags" do
  let(:filename) { 'test.txt' }

  specify ":Ctags" do

    vim.edit filename

    type ':Ctags<CR>'

    sleep 0.1
    File.exist?('tags').should be_true

  end
end
