vim.api.nvim_create_autocmd('FileType', {
  pattern = { '*' },
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    local lang = vim.treesitter.language.get_lang(ft) or ft
    if not lang or lang == '' then
      return
    end

    local ts = require 'nvim-treesitter'
    if not vim.list_contains(ts.get_available(), lang) then
      return
    end

    -- install if missing (no-op if already installed)
    pcall(function()
      ts.install { lang }
    end)

    -- enable if available
    if vim.treesitter.language.add(lang) then
      pcall(vim.treesitter.start, args.buf, lang)
      vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()' -- folds
      vim.wo.foldmethod = 'expr'
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" -- indentation
    end
  end,
})

return {
  {
    'neovim-treesitter/nvim-treesitter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    lazy = false,
    build = ':TSUpdate',
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    event = { 'BufReadPre' },
    dependencies = { 'neovim-treesitter/nvim-treesitter' },
    config = function()
      local context = require 'treesitter-context'

      context.setup()

      vim.keymap.set('n', '<leader>tc', function()
        context.toggle()
      end, { desc = 'Toggle Treesitter [C]ontext' })

      vim.keymap.set('n', '<leader>gc', function()
        context.go_to_context(vim.v.count1)
      end, { silent = true, desc = '[G]o to [C]ontext (upper)' })
    end,
  },
  -- {
  --   event = { 'BufReadPre' },
  --   'nvim-treesitter/nvim-treesitter-textobjects',
  --   dependencies = { 'neovim-treesitter/nvim-treesitter' },
  --   config = function()
  --     require('nvim-treesitter.configs').setup {
  --       textobjects = {
  --         select = {
  --           enable = true,
  --
  --           -- Automatically jump forward to textobj, similar to targets.vim
  --           lookahead = true,
  --
  --           keymaps = {
  --             -- You can use the capture groups defined in textobjects.scm
  --             ['af'] = '@function.outer',
  --             ['if'] = '@function.inner',
  --             ['ac'] = '@class.outer',
  --             -- You can optionally set descriptions to the mappings (used in the desc parameter of
  --             -- nvim_buf_set_keymap) which plugins like which-key display
  --             ['ic'] = { query = '@class.inner', desc = 'Select inner part of a class region' },
  --             -- You can also use captures from other query groups like `locals.scm`
  --             ['as'] = { query = '@scope', query_group = 'locals', desc = 'Select language scope' },
  --           },
  --           -- You can choose the select mode (default is charwise 'v')
  --           --
  --           -- Can also be a function which gets passed a table with the keys
  --           -- * query_string: eg '@function.inner'
  --           -- * method: eg 'v' or 'o'
  --           -- and should return the mode ('v', 'V', or '<c-v>') or a table
  --           -- mapping query_strings to modes.
  --           selection_modes = {
  --             ['@parameter.outer'] = 'v', -- charwise
  --             ['@function.outer'] = 'V', -- linewise
  --             ['@class.outer'] = 'V', -- linewise
  --           },
  --           -- If you set this to `true` (default is `false`) then any textobject is
  --           -- extended to include preceding or succeeding whitespace. Succeeding
  --           -- whitespace has priority in order to act similarly to eg the built-in
  --           -- `ap`.
  --           --
  --           -- Can also be a function which gets passed a table with the keys
  --           -- * query_string: eg '@function.inner'
  --           -- * selection_mode: eg 'v'
  --           -- and should return true or false
  --           include_surrounding_whitespace = false,
  --         },
  --       },
  --     }
  --   end,
  -- },
}
