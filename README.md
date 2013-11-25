# auto-ctags.vim

run the ctags command

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

Create tags

    :Ctags

Create at a Writing the file

    let g:auto_ctags = 1

## Policy
* Created in the current directory by default
* Create the version control directory in the configuration
* Can be extended settings in the filetype
* so that it can be used a minimum without any knowledge of tags

## ToDo
* Installation directory of version control
* Set ctags option
