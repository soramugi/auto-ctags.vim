require 'spec_helper'
require 'fileutils'

def file_exist(file)
  sleep 0.05
  expect(File).to exist(file)
  File.delete(file)
end

def file_not_exist(file)
  sleep 0.05
  expect(File).not_to exist(file)
end

def set_file_content(file, string)
  string = normalize_string_indent(string)
  File.open(file, 'w'){ |f| f.write(string) }
  File.absolute_path(file)
end

def vimrc(string)
  path = set_file_content('vimrc', string)
  vim.source path
end

describe "Auto Ctags" do
  let(:filename) { 'test.txt' }
  before do
    vim.edit filename
  end

  specify ":Ctags" do
    vim.command 'Ctags'

    file_exist 'tags'
  end

  specify "let g:auto_ctags = 1 & let g:auto_ctags_create_without_a_care = 1" do
    vimrc <<-EOF
      let g:auto_ctags = 1
      let g:auto_ctags_create_without_a_care = 1
    EOF

    vim.write

    file_exist 'tags'
  end

  specify "let g:auto_ctags = 1 & let g:auto_ctags_create_without_a_care = 0 &
  tag not exists" do
    vimrc <<-EOF
      let g:auto_ctags = 1
      let g:auto_ctags_create_without_a_care = 0
    EOF

    vim.write

    file_not_exist 'tags'
  end

  specify "let g:auto_ctags = 1 & let g:auto_ctags_create_without_a_care = 0 &
  tag exists" do
    FileUtils.touch('tags')
    a = File.mtime('tags')

    sleep 0.5

    vimrc <<-EOF
      let g:auto_ctags = 1
      let g:auto_ctags_create_without_a_care = 0
    EOF

    vim.write

    sleep 0.05

    b = File.mtime('tags')
    expect(a).not_to eq(b)
    File.delete('tags')
  end

  specify "let g:auto_ctags_directory_list = ['.git']" do

    vimrc <<-EOF
      let g:auto_ctags_directory_list = ['.git']
    EOF

    Dir.mkdir '.git'
    vim.command 'Ctags'

    file_exist '.git/tags'
  end

  specify "let g:auto_ctags_directory_list = ['.svn', '.git', '.']" do

    vimrc <<-EOF
      let g:auto_ctags_directory_list = ['.svn', '.git', '.']
    EOF

    vim.command 'Ctags'
    file_exist 'tags'
  end

  #specify "let g:auto_ctags_tags_name = 'huge.tags'" do

  #  vimrc <<-EOF
  #    let g:auto_ctags_tags_name = 'huge.tags'
  #  EOF

  #  vim.command 'Ctags'
  #  file_exist 'huge.tags'
  #end

  #specify "let g:auto_ctags_filetype_mode = 1" do
  #  vimrc <<-EOF
  #    let g:auto_ctags_filetype_mode = 1
  #  EOF

  #  vim.set 'filetype' 'vim'
  #  vim.command 'Ctags'
  #  file_exist 'vim.tags'
  #end

end
