require 'spec_helper'

describe 'auto-ctags.vim' do
  def repo_root
    File.expand_path('../..', __FILE__)
  end

  def run(command)
    VIM.command("#{command}")
  end

  describe ':Ctags' do
    it 'create the tags' do
      run("Ctags")
      path = repo_root + '/tags'
      File.exist?(path).should be_true
      File.delete(path)
    end
  end
end
