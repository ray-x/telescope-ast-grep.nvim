-- TODO: This should probably check your visual selection as well, if you've got one

local telescope = require('telescope')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local make_entry = require('telescope.make_entry')
local conf = require('telescope.config').values
local global = require('core.global')
local flatten = vim.tbl_flatten
local lprint = lprint or function(...) end

local escape_chars = function(string)
  return string.gsub(string, '[%(|%)|\\|%[|%]|%-|%{%}|%?|%+|%*|%^|%$]', {
    ['\\'] = '\\\\',
    ['-'] = '\\-',
    ['('] = '\\(',
    [')'] = '\\)',
    ['['] = '\\[',
    [']'] = '\\]',
    ['{'] = '\\{',
    ['}'] = '\\}',
    ['?'] = '\\?',
    ['+'] = '\\+',
    ['*'] = '\\*',
    ['^'] = '\\^',
    ['$'] = '\\$',
  })
end

local reg_go = function(word)
  local var = ''
  var = var .. string.format('\\s*\\b%s\\s*=[^=\\n]+|\\s*\\b%s\\s*:=\\s*', word, word)
  var = var .. string.format('|func\\s+\\([^\\)]*\\)\\s+%s\\s*\\(', word)
  var = var .. string.format('|func\\s+%s\\s*\\(', word)
  var = var .. string.format('|type\\s+%s\\s+struct\\s+\\{', word)
  return var
end

local regex_py = function(word)
  local var = ''
  var = var .. string.format('\\s*\\b%s\\s*=\\s*|\\s*\\b%s\\s*:\\s*', word, word)
  var = var .. string.format('|class\\s+%s\\s*\\(', word)
  var = var .. string.format('|def\\s+%s\\b\\s*\\(?', word)
  return var
end

local regex_js = function(word)
  local var = ''
  var = var .. string.format('\\s*\\b%s\\s*=\\s*|\\s*\\b%s\\s*:\\s*', word, word)
  var = var .. string.format('|class\\s+%s\\s*\\{', word)
  var = var .. string.format('|class\\s+%s\\s+extends', word)
  var = var .. string.format('|function\\s+%s\\s*\\(', word)
  var = var .. string.format('|\\b%s\\s*:\\s*function\\s*\\(', word)
  var = var .. string.format('|\\b%s\\s*\\([^()]*\\)\\s*[{]', word)
  return var
end
local regex_lua = function(word)
  local var = ''
  var = var .. string.format('\\s*\\b%s\\s*= [^=\\n]+\\s*', word, word)
  var = var .. string.format('|\\bfunction\\b[^\\(]*\\\\(\\s*[^\\)]*\\b%s\\b\\s*,?\\s*\\\\)?', word)
  -- function
  var = var .. string.format('|function\\s*%s\\s*\\(', word)
  var = var .. string.format('|function\\s*.+[.:]%s\\s*\\\\(', word)
  var = var .. string.format('|\\b%s\\s*=\\s*function\\s*\\\\(', word)
  var = var .. string.format('|\\b.+\\.%s\\s*=\\s*function\\s*\\\\(', word)
end
local regex_js = function(word)
  local var = ''
  var = var .. string.format('\\s*\\b%s\\s*=\\s*|\\s*\\b%s\\s*:\\s*', word, word)
  var = var .. string.format('|class\\s+%s\\s*\\{', word)
  var = var .. string.format('|class\\s+%s\\s+extends', word)
  var = var .. string.format('|function\\s+%s\\s*\\(', word)
  var = var .. string.format('|\\b%s\\s*:\\s*function\\s*\\(', word)
  var = var .. string.format('|\\b%s\\s*\\([^()]*\\)\\s*[{]', word)
  return var
end

local regex_cpp = function(word)
  local var = ''
  var = var
    .. string.format(
      '\\b%s(\\s|\\))*\\((\\w|[,&*.<>:]|\\s)*(\\))\\s*(const|->|\\{|$)|typedef\\s+(\\w|[(*]|\\s)+%s(\\)|\\s)*\\(',
      word,
      word
    )
  var = var
    .. string.format(
      '|\\b(?!(class\\b|struct\\b|return\\b|else\\b|delete\\b))(\\w+|[,>])([*&]|\\s)+%s\\s*(\\[(\\d|\\s)*\\])*\\s*([=,(){;]|:\\s*\\d)|#define\\s+%s\\b',
      word,
      word
    )
  var = var
    .. string.format(
      '|\\b(class|struct|enum|union)\\b\\s*%s\\b\\s*(final\\s*)?(:((\\s*\\w+\\s*::)*\\s*\\w*\\s*<?(\\s*\\w+\\s*::)*\\w+>?\\s*,*)+)?((\\{|$))|}\\s*%s\\b\\s*;',
      word,
      word
    )
  return var
end

local regex_typescript = function(word)
  return regex_js(word)
end

local dumb_jump = function(opts)
  local vimgrep_arguments = opts.vimgrep_arguments or conf.vimgrep_arguments
  local search_dirs = opts.search_dirs
  local word = opts.search or vim.fn.expand('<cword>')

  local var
  if vim.bo.filetype == 'go' then
    var = reg_go(word)
  elseif vim.bo.filetype == 'python' then
    var = regex_py(word)
  elseif vim.bo.filetype == 'lua' then
    var = regex_lua(word)
  elseif vim.bo.filetype == 'javascript' then
    var = regex_js(word)
  elseif vim.bo.filetype == 'typescript' then
    var = regex_typescript(word)
  elseif vim.bo.filetype == 'cpp' or vim.bo.filetype == 'c'  then
    var = regex_cpp(word)
  else
    var = word
  end

  lprint(var)

  local search = var
  local word_match = opts.word_match
  opts.entry_maker = opts.entry_maker or make_entry.gen_from_vimgrep(opts)

  local additional_args = {}
  if opts.additional_args ~= nil and type(opts.additional_args) == 'function' then
    additional_args = opts.additional_args(opts)
  end

  local args = flatten({
    vimgrep_arguments,
    additional_args,
    word_match,
    '--',
    search,
  })

  if search_dirs then
    for _, path in ipairs(search_dirs) do
      table.insert(args, vim.fn.expand(path))
    end
  else
    table.insert(args, '.')
  end

  pickers
    .new(opts, {
      prompt_title = 'dumb jump (' .. word .. ')',
      finder = finders.new_oneshot_job(args, opts),
      previewer = conf.grep_previewer(opts),
      sorter = conf.generic_sorter(opts),
    })
    :find()
end

return telescope.register_extension({ exports = { dumb_jump = dumb_jump } })
