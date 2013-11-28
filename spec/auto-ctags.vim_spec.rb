require 'vimrunner'

vim = Vimrunner.start
vim.add_plugin(File.expand_path('../..', __FILE__), 'plugin/auto-ctags.vim')

describe 'auto-ctags.vim' do
  after(:all) do
    vim.kill
  end

  describe ':Ctags' do
    it 'create the tags' do
      vim.command(':Ctags')
      File.file?('tags').should
    end
  end
end
