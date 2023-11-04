local telescope = require('telescope')
local lprint = lprint or function(...) end

local function simplifyLine(line)
  local pre, match, post = line:match('(.*:%d+:%d+:)(%d+:%d+:)(.*)')
  if match and not post:match('^".*') and not post:match("^'.*") then
    line = pre .. post
  end
  return line
end
local AST_grep = function(opts)
  local ft = vim.bo.filetype
  local finders = require('telescope.finders')
  local pickers = require('telescope.pickers')
  local make_entry = require('telescope.make_entry')
  local conf = require('telescope.config').values
  local flatten = vim.tbl_flatten

  local sorters = require('telescope.sorters')
  local setup_opts = { min_len = 4 }
  opts = vim.tbl_extend('force', setup_opts, opts or {})
  opts.entry_maker = opts.entry_maker or make_entry.gen_from_vimgrep(opts)
  opts.cwd = opts.cwd and vim.fn.expand(opts.cwd)
  if opts.search_dirs then
    for i, path in ipairs(opts.search_dirs) do
      opts.search_dirs[i] = vim.fn.expand(path)
    end
  end

  local cmd_generator = function(prompt)
    if vim.fn.empty(prompt) == 1 or #prompt < setup_opts.min_len then
      return nil
    end
    lprint(vim.inspect(prompt))
    local ast_grep_cmd = {} -- only if using windows
    if vim.fn.executable('sg') == 1 then
      table.insert(ast_grep_cmd, 'sg')
    else
      table.insert(ast_grep_cmd, 'ast_grep')
    end
    ast_grep_cmd =
      vim.list_extend(ast_grep_cmd, { '-p', "'" .. prompt .. "'", '-l', ft, '--json', '|' })
    ast_grep_cmd = {
      'sh',
      '-c',
      [[sg -p ]]
        .. string.format("'%s' -l %s", prompt, ft)
        .. [[ --json=stream | jq -r '"\(.file):\((.range.start.line + 1)):\((.range.start.column + 1)):\((.range.end.line + 1)):\((.range.end.column + 1)): \(.lines)" |
        split("\n") | .[0]']],
    }
    lprint(ast_grep_cmd)
    return ast_grep_cmd
  end

  local grepper = make_entry.gen_from_vimgrep(opts)
  local entry_maker = function(line)
    local _, _, filename, lnum, col, lnend, colend, text =
      string.find(line, [[(..-):(%d+):(%d+):(%d+):(%d+):(.*)]])
    lprint(line, filename, lnum, col, lnend, colend, text)
    line = simplifyLine(line)
    local mt = grepper(line)
    mt.finish = lnend
    mt.lnend = lnend
    mt.colend = colend
    -- print(vim.inspect(mt), vim.inspect(mt.lnum))
    return mt
  end

  lprint(opts)
  pickers
    .new(opts, {
      prompt_title = 'AST Grep',
      finder = finders.new_job(cmd_generator, entry_maker, _, opts.cwd),
      previewer = conf.grep_previewer(opts),
      sorter = sorters.highlighter_only(opts),
    })
    :find()
end

return telescope.register_extension({
  setup = function(ext_config)
    -- add config
  end,
  exports = {
    AST_grep = AST_grep, -- historical name
  },
})
