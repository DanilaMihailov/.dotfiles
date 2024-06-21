-- автокомплит, go to definition (LSP, Mason, nvim-cmp)
-- подсветка синтакса (Treesitter)
-- поиск по файлам (telescope, neo-tree)
-- интеграция с гит (fugitive, gitsigns, telescope)
-- автоформатирование (conform, lsp)
--
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.opt`
--
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- vim.o.keymap = 'russian-jcukenwin' -- allow use russian keys for moves and stuff
--
-- allows using motions in russian language
vim.opt.langmap =
  'ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz'

-- helps gf to find files
-- ** - all files from root
-- .  - relative from current
-- ,, - relative from current in same dir
vim.opt.path = vim.opt.path + '**,.,,'

vim.opt.showtabline = 0

vim.g.loaded_python3_provider = false
vim.g.loaded_ruby_provider = false
vim.g.loaded_perl_provider = false
vim.g.loaded_node_provider = false

vim.o.shell = '/bin/zsh' -- use zsh as default shell

-- use ripgrep for :grep command
-- if vim.fn.executable 'rg' == 1 then
--   vim.o.grepprg = 'rg --vimgrep --hidden'
-- end

vim.filetype.add {
  pattern = {
    ['.*%.js%.ejs'] = 'javascript',
    ['.*%.html%.ejs'] = 'html',
    ['.*%.json%.ejs'] = 'json',
  },
}

vim.o.sessionoptions =
  'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'

vim.cmd.colorscheme 'retrobox' -- default colorscheme, overriden by plugins

-- Make searching better
vim.opt.gdefault = true -- Never have to type /g at the end of search / replace again

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.opt.clipboard = 'unnamedplus'

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.g.show_diagnostic_virutal_text = true
-- Diagnostic keymaps
vim.diagnostic.config {
  severity_sort = true,
  virtual_text = vim.g.show_diagnostic_virutal_text,
}

-- Diagnostic keymaps
-- vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
-- vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
-- vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set(
  'n',
  '<leader>q',
  vim.diagnostic.setloclist,
  { desc = 'Open diagnostic [Q]uickfix list' }
)
vim.keymap.set('n', '<leader>td', function()
  vim.g.show_diagnostic_virutal_text = not vim.g.show_diagnostic_virutal_text
  vim.diagnostic.config { virtual_text = vim.g.show_diagnostic_virutal_text }
end, { desc = '[T]oggle [D]iagnostics' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', 'y<C-g>', function()
  local bufname = vim.api.nvim_buf_get_name(0)
  local cwd = vim.uv.cwd()
  if not cwd then
    return
  end
  local relPath = '.' .. bufname:gsub(cwd, '') .. ':' .. vim.fn.line '.'
  vim.notify('Copied path to clipboard\n' .. relPath, vim.log.levels.INFO)
  vim.fn.setreg(vim.v.register, relPath)
end, { desc = 'Yank relative file path' })
-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('n', 'gh', '_', { desc = 'Move cursor to the begining of line (_)' })
vim.keymap.set('n', 'gl', '$', { desc = 'Move cursor to the end of line ($)' })

vim.keymap.set('n', '<leader>`', '<C-^>', { desc = 'Switch to other buffer (C-^)' })
-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- folds using treesitter
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldenable = false -- do not fold by default
vim.opt.foldtext = '' -- "transparent folds - just text with syntax highlight"
vim.opt.fillchars = 'fold: '
vim.opt.fillchars = 'eob: ' -- hide end of buffer '~' symbol

-- Switch between tabs
vim.keymap.set('n', '<A-l>', function()
  vim.api.nvim_feedkeys('gt', 'n', true)
end, { desc = 'Next tab' })

vim.keymap.set('n', '<A-h>', function()
  vim.api.nvim_feedkeys('gT', 'n', true)
end, { desc = 'Previous tab' })

local termgroup = vim.api.nvim_create_augroup('mytermgroup', { clear = true })
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = '*',
  group = termgroup,
  desc = 'Hide line numbers in terminal',
  callback = function()
    vim.opt_local.relativenumber = false
    vim.opt_local.number = false
    vim.opt_local.signcolumn = 'no'
    vim.opt_local.cursorline = false
  end,
})

-- vim.opt.wildmode = 'longest:full,list:longest,full' -- complete longest string
-- vim.o.wildignorecase = true -- ignore file names and dirs case when completing

-- Jump to last edit position on opening file
-- https://stackoverflow.com/questions/31449496/vim-ignore-specifc-file-in-autocommand
vim.cmd [[
augroup mygrouplastposition
    autocmd!
    au BufReadPost * if expand('%:p') !~# '\m/\.git/' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
augroup end
]]

vim.keymap.set('t', '<C-W>N', '<C-\\><C-n>', { desc = 'Change terminal mode to normal as in vim' })
vim.keymap.set('t', '<C-W>n', '<C-\\><C-n>', { desc = 'Change terminal mode to normal as in vim' })
vim.keymap.set(
  't',
  '<C-W>',
  '<C-\\><C-N><C-w>',
  { desc = 'Move out of terminal as if it is just a window' }
)

-- vim.keymap.set('n', '<leader>-', ':wincmd _<cr>:wincmd \\|<cr>', { desc = 'Zoom on pane' })
-- vim.keymap.set('n', '<leader>=', ':wincmd =<cr>', { desc = 'Rebalance panes' })

-- Search results centered please
vim.keymap.set('n', 'n', 'nzz', { silent = true, desc = 'n, but centered' })
vim.keymap.set('n', 'N', 'Nzz', { silent = true, desc = 'N, but centered' })
vim.keymap.set('n', '*', '*zz', { silent = true, desc = '*, but centered' })
vim.keymap.set('n', '#', '#zz', { silent = true, desc = '#, but centered' })
vim.keymap.set('n', 'g*', 'g*zz', { silent = true, desc = 'g*, but centered' })

vim.keymap.set(
  'n',
  '<C-x><C-f>',
  ':e <C-R>=expand("%:p:h") . "/" <CR>',
  { desc = 'Open new file adjacent to current file like emacs' }
)

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require('lazy').setup({
  -- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
  'danilamihailov/vim-tips-wiki',

  {
    dir = '~/personal/nvim-plugins/beacon.nvim/',
    opts = {
      enabled = function()
        if vim.bo.ft:find 'Neogit' then
          return false
        end
        return true
      end,
    },
    config = true,
  },

  -- 'tpope/vim-surround', -- Surrond with braces ysB
  'tpope/vim-repeat', -- enable repeat for tpope's plugins
  { 'tpope/vim-unimpaired', keys = { '[', ']' } }, -- ]b for next buffer, ]e for exchange line, etc
  { -- Bdelete [other, hidden, this]
    'Asheq/close-buffers.vim',
    config = function()
      vim.keymap.set(
        'n',
        '<leader><leader>bo',
        '<cmd>Bdelete other<cr>',
        { desc = '[B]uffer Delete [O]ther' }
      )
      vim.keymap.set(
        'n',
        '<leader><leader>bh',
        '<cmd>Bdelete hidden<cr>',
        { desc = '[B]uffer Delete [H]idden' }
      )
    end,
  },

  -- NOTE: Plugins can also be added by using a table,
  -- with the first argument being the link and the following
  -- keys can be used to configure plugin behavior/loading/etc.
  --
  -- Use `opts = {}` to force a plugin to be loaded.
  --
  --  This is equivalent to:
  --    require('Comment').setup({})

  -- "gc" to comment visual regions/lines
  -- disable for now, use builtin
  -- { 'numToStr/Comment.nvim', opts = {}, keys = { 'gc' } },

  -- NOTE: Plugins can also be configured to run Lua code when they are loaded.
  --
  -- This is often very useful to both group configuration, as well as handle
  -- lazy loading plugins that don't need to be loaded immediately at startup.
  --
  -- For example, in the following configuration, we use:
  --  event = 'VimEnter'
  --
  -- which loads which-key before all the UI elements are loaded. Events can be
  -- normal autocommands events (`:help autocmd-events`).
  --
  -- Then, because we use the `config` key, the configuration only runs
  -- after the plugin has been loaded:
  --  config = function() ... end

  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VeryLazy', -- Sets the loading event to 'VimEnter'
    config = function() -- This is the function that runs, AFTER loading
      require('which-key').setup {
        window = {
          winblend = 20,
        },
      }

      -- Document existing key chains
      require('which-key').register {
        ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
        ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
        ['<leader>r'] = { name = '[R]un', _ = 'which_key_ignore' },
        ['<leader>rt'] = { name = '[R]un [T]ests', _ = 'which_key_ignore' },
        ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
        ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
        ['<leader>t'] = { name = '[T]oggle', _ = 'which_key_ignore' },
        ['<leader>h'] = { name = 'Git [H]unk', _ = 'which_key_ignore' },
        ['<leader><leader>'] = { name = '[ ] Additional commands', _ = 'which_key_ignore' },
        ['<leader><leader>g'] = { name = '[G]it commands', _ = 'which_key_ignore' },
        ['<leader><leader>b'] = { name = '[B]uffer commands', _ = 'which_key_ignore' },
      }
      -- visual mode
      require('which-key').register({
        ['<leader>h'] = { 'Git [H]unk' },
      }, { mode = 'v' })
    end,
  },

  -- NOTE: Plugins can specify dependencies.
  --
  -- The dependencies are proper plugin specifications as well - anything
  -- you do for a plugin at the top level, you can do for a dependency.
  --
  -- Use the `dependencies` key to specify the dependencies of a particular plugin

  {
    'folke/trouble.nvim',
    cmd = 'Trouble',
    opts = {}, -- for default options, refer to the configuration section for custom setup.
  },
  {
    'danymat/neogen',
    cmd = 'Neogen',
    config = true,
    opts = {
      snippet_engine = 'luasnip',
    },
    -- Uncomment next line if you want to follow only stable versions
    -- version = "*"
  },

  -- Highlight todo, notes, etc in comments
  {
    'folke/todo-comments.nvim',
    event = 'BufRead',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    event = 'VeryLazy',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [']quote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      require('mini.git').setup()
    end,
  },

  -- The following two comments only work if you have downloaded the kickstart repo, not just copy pasted the
  -- init.lua. If you want these files, they are in the repository, so you can just download them and
  -- place them in the correct locations.

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
  --
  --  Here are some example plugins that I've included in the Kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'kickstart.plugins.debug',
  require 'kickstart.plugins.indent_line',
  require 'kickstart.plugins.lint',
  require 'kickstart.plugins.autopairs',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    This is the easiest way to modularize your config.
  --
  --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --    For additional information, see `:help lazy.nvim-lazy.nvim-structuring-your-plugins`
  { import = 'custom.plugins' },
  {
    'stevearc/oil.nvim',
    cmd = 'Oil',
    ---@type oil.setupOpts
    opts = {
      win_options = {
        signcolumn = 'yes:2',
        winbar = '%F',
      },
      skip_confirm_for_simple_edits = true,
      delete_to_trash = true,
      view_options = {
        show_hidden = true,
      },
      keymaps = {
        ['<C-p>'] = {
          desc = 'Open preview in horizontal split',
          callback = function()
            local oil = require 'oil'
            local util = require 'oil.util'
            local entry = oil.get_cursor_entry()
            if not entry then
              vim.notify('Could not find entry under cursor', vim.log.levels.ERROR)
              return
            end
            local winid = util.get_preview_win()
            if winid then
              local cur_id = vim.w[winid].oil_entry_id
              if entry.id == cur_id then
                vim.api.nvim_win_close(winid, true)
                return
              end
            end
            oil.open_preview {
              horizontal = true,
              split = 'belowright',
            }
          end,
        },
        ['<C-y>'] = {
          desc = 'Copy relative path to clipboard',
          callback = function()
            local oil = require 'oil'
            local entry = oil.get_cursor_entry()
            local dir = oil.get_current_dir()
            local cwd = vim.uv.cwd()
            if not entry or not dir or not cwd then
              return
            end
            local relPath = '.' .. dir:gsub(cwd, '') .. entry.name
            vim.notify('Copied path to clipboard\n' .. relPath, vim.log.levels.INFO)
            vim.fn.setreg(vim.v.register, relPath)
          end,
        },
        ['<C-q>'] = 'actions.send_to_qflist',
      },
    },
    -- Optional dependencies
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    init = function()
      vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
      vim.keymap.set('n', '_', function()
        require('oil').open(vim.uv.cwd())
      end, { desc = 'Open CWD' })
    end,
  },
  -- {
  --   'refractalize/oil-git-status.nvim',
  --   lazy = true,
  --   dependencies = {
  --     'stevearc/oil.nvim',
  --   },
  --   config = true,
  -- },
  {
    'brenoprata10/nvim-highlight-colors',
    event = 'BufRead',
    opts = {
      render = 'virtual',
      enable_tailwind = true,
      virtual_symbol = '●',
    },
  },
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    ft = { 'markdown' },
    build = function()
      vim.fn['mkdp#util#install']()
    end,
    init = function()
      -- open preview in little arc
      vim.cmd [[
        function OpenMarkdownPreview (url)
          execute "silent ! osascript -e 'tell application \"Arc\"' -e 'make new tab with properties {URL:\"" . a:url . "\"}' -e 'activate' -e 'end tell'"
        endfunction
        let g:mkdp_browserfunc = 'OpenMarkdownPreview'
        ]]
    end,
  },
  {
    'mikesmithgh/kitty-scrollback.nvim',
    enabled = true,
    lazy = true,
    cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth' },
    event = { 'User KittyScrollbackLaunch' },
    -- version = '*', -- latest stable version, may have breaking changes if major version changed
    -- version = '^5.0.0', -- pin major version, include fixes and features that do not have breaking changes
    config = function()
      require('kitty-scrollback').setup()
    end,
  },
  {
    'numToStr/FTerm.nvim',
    lazy = true,
    cmd = { 'FTermToggle' },
    keys = { '<leader>i' },
    config = function()
      local fterm = require 'FTerm'

      fterm.setup {
        border = 'rounded',
      }

      vim.keymap.set({ 'n', 't' }, '<leader>i', function()
        fterm.toggle()
      end, { desc = 'Toggle FTerm' })

      vim.api.nvim_create_user_command(
        'FTermToggle',
        require('FTerm').toggle,
        { bang = true, desc = 'Toggle FTerm' }
      )
    end,
  },
  { 'fladson/vim-kitty' },
}, {
  -- defaults = {
  --   lazy = true,
  -- },
  ui = {
    border = 'rounded',
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
  checker = {
    enable = true,
  },
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        'gzip',
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
  profiling = {
    -- Enables extra stats on the debug tab related to the loader cache.
    -- Additionally gathers stats about all package.loaders
    loader = false,
    -- Track each new require in the Lazy profiling tab
    require = false,
  },
})

-- check for plugins updates, lualine shows counter
require('lazy').check {
  show = false,
}

local icons = {
  E = '󰅚 ',
  W = '󰀪 ',
  H = '󰋽 ',
  I = '󰌶 ',
}

vim.diagnostic.config {
  underline = true,
  update_in_insert = false,
  virtual_text = {
    spacing = 0,
    source = 'if_many',
    -- show icons in prefix
    prefix = function(diagnostic)
      for d, icon in pairs(icons) do
        if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
          return icon
        end
      end
      return '●'
    end,
  },
  jump = {
    float = true,
  },
  float = {
    border = 'rounded',
    severity_sort = true,
    source = 'if_many',
    -- show icons in prefix
    prefix = function(diagnostic)
      for d, icon in pairs(icons) do
        if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
          return icon
        end
      end
      return '●'
    end,
  },
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = icons.E,
      [vim.diagnostic.severity.WARN] = icons.W,
      [vim.diagnostic.severity.HINT] = icons.H,
      [vim.diagnostic.severity.INFO] = icons.I,
    },
  },
}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
