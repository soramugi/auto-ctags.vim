# auto-ctags.vim

run the ctags command

[![Build Status](https://travis-ci.org/soramugi/auto-ctags.vim.png?branch=master)](https://travis-ci.org/soramugi/auto-ctags.vim)

## Usage

Use [neobundle](https://github.com/Shougo/neobundle.vim) to install the plugin.

The postscript to `~/.vimrc` the next.

```
NeoBundle 'soramugi/auto-ctags.vim'
```

or

    $ mkdir -p ~/.vim/plugin
    $ git clone https://github.com/soramugi/auto-ctags.vim.git ~/.vim/plugin/auto-ctags.vim.git

## Setting

requires `ctags` utility. please install

On Debian

    sudo apt-get install exuberant-ctags

On OSX

    brew install ctags

Create tags

    :Ctags

Create at a Writing the file, default `0`

    let g:auto_ctags = 1

Create the tags in directory, default `.`

And stored in a directory that matches the first

    let g:auto_ctags_directory_list = ['.git', '.svn']

Create the tags name, default `tags`

    let g:auto_ctags_tags_name = 'tags'

Create the ctags args, default `--tag-relative --recurse --sort=yes`

    let g:auto_ctags_tags_args = ['--tag-relative=yes', '--recurse=yes', '--sort=yes']

Create the filetype tags `--languages=` option mode, default `0`

    let g:auto_ctags_filetype_mode = 1

Set a valid tags option by calling `:setlocal tags^=<tags file name>` per buffers

    :CtagsSetTagsOption

Call automatically `:CtagsSetTagsOption` when BufNewFile and BufRead are triggered, default `0`

    let g:auto_ctags_set_tags_option = 1

Show all warning messages only once, default `0`

    let g:auto_ctags_warn_once = 1

## Testing

Please install `docker`

    sh run-test.sh

## Policy
* Created in the current directory by default
* Create the version control directory in the configuration
* Can be extended settings in the filetype
* so that it can be used a minimum without any knowledge of tags
