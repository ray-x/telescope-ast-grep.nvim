local telescope = require('telescope')
local lprint = lprint or function(...) end
local ast_grep = function(opts)
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
        .. [[ --json | jq -r '.[] | "\(.file):\((.range.start.line + 1)):\((.range.start.column + 1)):\(.lines)" |
        split("\n") | .[0]']],
    }
    lprint(ast_grep_cmd)
    return ast_grep_cmd
  end

  -- apply theme
  if type(opts.theme) == 'table' then
    opts = vim.tbl_extend('force', opts, opts.theme)
  elseif type(opts.theme) == 'string' then
    local themes = require('telescope.themes')
    if themes['get_' .. opts.theme] == nil then
      vim.notify_once(
        'live grep args config theme »' .. opts.theme .. '« not found',
        vim.log.levels.WARN
      )
    else
      opts = themes['get_' .. opts.theme](opts)
    end
  end

  opts.entry_maker = opts.entry_maker or make_entry.gen_from_vimgrep(opts)
  lprint(opts)
  pickers
    .new(opts, {
      prompt_title = 'AST Grep',
      finder = finders.new_job(cmd_generator, opts.entry_maker, _, opts.cwd),
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
    ast_grep = ast_grep, -- historical name
  },
})
