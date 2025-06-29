return { -- Fuzzy Finder (files, lsp, etc)
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  config = function()
    -- See `:help telescope` and `:help telescope.setup()`
    local actions = require 'telescope.actions'
    local themes = require 'telescope.themes'
    require('telescope').setup {
      defaults = {
        borderchars = {
          { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
          prompt = { '─', '│', ' ', '│', '┌', '┐', '│', '│' },
          results = { '─', '│', '─', '│', '├', '┤', '┘', '└' },
          preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
        },
        dynamic_preview_title = true,
        results_title = false,
        path_display = { 'truncate' },
        mappings = {
          i = {
            ['<c-enter>'] = 'to_fuzzy_refine',
            ['<esc>'] = actions.close,
          },
        },
      },
      pickers = {
        find_files = themes.get_ivy(),
        help_tags = themes.get_ivy(),
        keymaps = themes.get_ivy(),
        builtin = themes.get_ivy(),
        grep_string = themes.get_ivy(),
        live_grep = themes.get_ivy(),
        diagnostics = themes.get_ivy(),
        resume = themes.get_ivy(),
        oldfiles = themes.get_ivy(),
        lsp_references = themes.get_ivy(),
        lsp_implementations = themes.get_ivy(),
        lsp_definitions = themes.get_ivy(),
        lsp_document_symbols = themes.get_ivy(),
        lsp_dynamic_workspace_symbols = themes.get_ivy(),
        lsp_type_definitions = themes.get_ivy(),
      },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_ivy(),
        },
      },
    }

    local function iw(picker, opts)
      local function inner()
        picker(themes.get_ivy(opts))
      end

      return inner
    end

    -- Enable Telescope extensions if they are installed
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    -- See `:help telescope.builtin`
    local builtin = require 'telescope.builtin'
    vim.keymap.set('n', '<leader>sb', iw(builtin.buffers), { desc = '[S]earch [B]uffers' })
    vim.keymap.set('n', '<leader>sc', iw(builtin.commands), { desc = '[S]earch [C]ommands' })
    vim.keymap.set(
      'n',
      '<leader>sC',
      iw(builtin.colorscheme, { enable_preview = true }),
      { desc = '[S]earch [C]olorscheme' }
    )

    vim.keymap.set('n', '<leader>st', iw(builtin.treesitter), { desc = '[S]earch [T]reesitter' })
    vim.keymap.set(
      'n',
      '<leader><leader>gc',
      iw(builtin.git_branches),
      { desc = '[G]it [C]heckout' }
    )
    vim.keymap.set('n', '<leader><leader>gf', iw(builtin.git_files), { desc = '[G]it [F]iles' })

    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
    vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set(
      'n',
      '<leader>s.',
      builtin.oldfiles,
      { desc = '[S]earch Recent Files ("." for repeat)' }
    )

    -- Slightly advanced example of overriding default behavior and theme
    vim.keymap.set('n', '<leader>/', function()
      -- You can pass additional configuration to Telescope to change the theme, layout, etc.
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc = '[/] Fuzzily search in current buffer' })

    -- It's also possible to pass additional configuration options.
    --  See `:help telescope.builtin.live_grep()` for information about particular keys
    vim.keymap.set('n', '<leader>s/', function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, { desc = '[S]earch [/] in Open Files' })

    -- Shortcut for searching your Neovim configuration files
    vim.keymap.set('n', '<leader>sn', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })
  end,
}
