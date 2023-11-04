# telescope-ast-grep.nvim

`telescope-ast-grep.nvim` provides grep functionality enhancements for telescope.nvim, featuring two main components:
- `ast_grep`: AST based grep
- `dumb_jump`: grep by regex [emacs-dumb-jump](https://github.com/jacktasia/dumb-jump)

Currently, the extension supports a limited set of languages.
- For ast_grep, check supported languages [here](https://github.com/ast-grep/ast-grep)
- dumb_jump, Please refer to the source code for current language support. As of now, I've integrated support for python, go, and js/ts, which are the languages I most frequently use.

## Requirements
- [install ast-grep](https://github.com/ast-grep/ast-grep#installation)
- jq
- ripgrep
- shell (The plugin can run under windows with bash/mingw)

## Installation
```lua
{
  'ray-x/telescope-ast-grep.nvim',
  dependencies = {
    {'nvim-lua/plenary.nvim'},
    {'nvim-telescope/telescope.nvim'},
  },
  config = function()
  end
}
```

### Screenshot

<img width="723" alt="image" src="https://user-images.githubusercontent.com/1681295/280444212-e6aeee3d-7305-4e44-bf0b-444dca15a693.png">


<img width="726" alt="image" src="https://user-images.githubusercontent.com/1681295/280444283-ebe5159e-a3d8-4291-b642-a7c8903a08a0.png">
