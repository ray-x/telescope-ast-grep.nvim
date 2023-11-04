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
}
```

### Screenshot

<img width="720" alt="image" src="https://user-images.githubusercontent.com/1681295/280497477-794da50e-9f56-4e4b-b0d3-6e5a8c3a1433.png">
<img width="720" alt="image" src="https://user-images.githubusercontent.com/1681295/280444283-ebe5159e-a3d8-4291-b642-a7c8903a08a0.png">

### Similar plugins

- [telescope-sg](https://github.com/Marskey/telescope-sg)
- [any-jump.vim](https://github.com/pechorin/any-jump.vim)

