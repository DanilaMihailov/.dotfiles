-- auto install packer
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
    packer_bootstrap = fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim',
        install_path })
    vim.cmd [[packadd packer.nvim]]
end

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'
    use 'lewis6991/impatient.nvim'
    -- use 'gruvbox-community/gruvbox'
    use { "ellisonleao/gruvbox.nvim" }

    -- Highlights
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
    }

    use { "tpope/vim-fugitive", requires = "tpope/vim-dispatch" }
    use { 'TimUntersberger/neogit', requires = 'nvim-lua/plenary.nvim' }
    use {
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup()
        end
    }

    use {
        'nvim-telescope/telescope.nvim', branch = '0.1.x',
        requires = { { 'nvim-lua/plenary.nvim' } }
    }
    use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }


    -- LSP
    use {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "neovim/nvim-lspconfig",
    }

    use { 
        'mhartington/formatter.nvim',
        config = function ()
            require("formatter").setup {
              filetype = {
                python = { require("formatter.filetypes.python").black },

              }
            }
        end
    }

    -- Completion
    use {
        'hrsh7th/nvim-cmp',
        requires = {
            'L3MON4D3/LuaSnip',
            { 'hrsh7th/cmp-buffer', after = 'nvim-cmp' },
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-nvim-lsp-signature-help',
            { 'hrsh7th/cmp-path', after = 'nvim-cmp' },
            { 'hrsh7th/cmp-nvim-lua', after = 'nvim-cmp' },
            { 'saadparwaiz1/cmp_luasnip', after = 'nvim-cmp' },
            { 'hrsh7th/cmp-nvim-lsp-document-symbol', after = 'nvim-cmp' },
        }
    }
    use { "nvim-telescope/telescope-file-browser.nvim" }
    use {
        'kyazdani42/nvim-tree.lua',
        requires = {
            'kyazdani42/nvim-web-devicons', -- optional, for file icons
        },
        config = function ()
            local nvim_tree = require("nvim-tree")
            local nvim_tree_api = require("nvim-tree.api")
            nvim_tree.setup({
                view = {
                    adaptive_size = true,
                    float = {
                        enable = false,
                        open_win_config = {
                            width = 50,
                            height = 50
                        }
                    }
                },
                renderer = {
                    symlink_destination = false,
                    indent_markers = {
                        enable = true,
                        icons = { corner = "└", edge = "│", item = "│", bottom = "─", none = " ", },
                        inline_arrows = true
                    }
                }
            })

            vim.keymap.set("n", "<C-f>", function ()
                nvim_tree_api.tree.toggle(true)
            end)
        end
    }
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true },
    }
    use 'arkav/lualine-lsp-progress'

    -- Motion and helpers
    use 'wellle/targets.vim' -- make bracets motions find closest bracket and more
    use 'andymass/vim-matchup' -- better brackets highlihgts and motion
    use 'tpope/vim-surround' -- Surrond with braces ysB
    use 'tpope/vim-repeat' -- enable repeat for tpope's plugins

    use { -- gcc to comment line
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
    }
    use 'tpope/vim-unimpaired' -- ]b for next buffer, ]e for exchange line, etc
    use 'bkad/CamelCaseMotion' -- move by camel case words with Space + Motion
    use {
        "windwp/nvim-autopairs",
        after = "nvim-cmp",
        config = function()
            require("nvim-autopairs").setup {}
            local cmp_autopairs = require('nvim-autopairs.completion.cmp')
            local cmp = require('cmp')
            cmp.event:on(
                'confirm_done',
                cmp_autopairs.on_confirm_done()
            )
        end
    }
    use 'skywind3000/vim-quickui'
    use {
        'goolord/alpha-nvim',
        config = function()
            require 'alpha'.setup(require 'alpha-theme'.config)
        end
    }
    use {
        'Shatur/neovim-session-manager',
        config = function()
            local cfg = require('session_manager.config')
            require('session_manager').setup({
                autoload_mode = cfg.AutoloadMode.Disabled
            })
        end,
        requires = { { 'nvim-lua/plenary.nvim' } },
    }
    use {
        'nvim-telescope/telescope-ui-select.nvim',
        after = "telescope.nvim",
        config = function()
            require("telescope").load_extension("ui-select")
        end
    }
    use 'Asheq/close-buffers.vim' -- Bdelete [other, hidden, this]
end)
