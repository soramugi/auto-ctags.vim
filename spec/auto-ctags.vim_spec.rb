require 'spec_helper'

describe 'auto-ctags.vim' do
  def repo_root()
    File.expand_path('../..', __FILE__)
  end

  def runcommand(command)
    VIM.command("command")
  end

  describe ':Ctags' do
    after(:each) do
    end
    it 'create the tags' do
      runcommand(':Ctags')
      FileTest.exist?(repo_root + '/tags').should be_true
      File.delete(repo_root + '/tags')
    end
  end
end
