vim.pack.add {
  'https://github.com/neovim-treesitter/nvim-treesitter',
  'https://github.com/nvim-treesitter/nvim-treesitter-context',
}

-- for some languages query files depend on another
-- javascript -> ecma, jsx
-- html -> html_tags

vim.api.nvim_create_autocmd('FileType', {
  pattern = { '*' },
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    local lang = vim.treesitter.language.get_lang(ft) or ft
    if not lang or lang == '' then
      -- vim.notify('Lang not found: ' .. lang, vim.log.levels.INFO, { title = 'TS' })
      return
    end

    local ts = require 'nvim-treesitter'
    if not vim.list_contains(ts.get_available(), lang) then
      -- vim.notify('Lang not available: ' .. lang, vim.log.levels.INFO, { title = 'TS' })
      return
    end

    -- install if missing (no-op if already installed)
    pcall(function()
      ts.install { lang }
    end)

    -- enable if available
    if pcall(vim.treesitter.start, args.buf, lang) then
      vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()' -- folds
      vim.wo.foldmethod = 'expr'
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" -- indentation
    else
      vim.notify('Treesitter not started: ' .. lang, vim.log.levels.WARN, { title = 'TS' })
    end
  end,
})

vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == 'nvim-treesitter' and kind == 'update' then
      if not ev.data.active then
        vim.cmd.packadd 'nvim-treesitter'
      end
      vim.cmd 'TSUpdate'
    end
  end,
})

local context = require 'treesitter-context'

context.setup()

vim.keymap.set('n', '<leader>tc', function()
  context.toggle()
end, { desc = 'Toggle Treesitter [C]ontext' })

vim.keymap.set('n', '<leader>gc', function()
  context.go_to_context(vim.v.count1)
end, { silent = true, desc = '[G]o to [C]ontext (upper)' })
