return {
  'maskudo/devdocs.nvim',
  lazy = false,
  dependencies = {
    'folke/snacks.nvim',
  },
  cmd = { 'DevDocs' },
  keys = {
    {
      '<leader>ho',
      mode = 'n',
      '<cmd>DevDocs get<cr>',
      desc = 'Get Devdocs',
    },
    {
      '<leader>hi',
      mode = 'n',
      '<cmd>DevDocs install<cr>',
      desc = 'Install Devdocs',
    },
    {
      '<leader>hv',
      mode = 'n',
      function()
        local devdocs = require 'devdocs'
        local installedDocs = devdocs.GetInstalledDocs()
        vim.ui.select(installedDocs, {}, function(selected)
          if not selected then
            return
          end
          local docDir = devdocs.GetDocDir(selected)
          -- prettify the filename as you wish
          Snacks.picker.files { cwd = docDir }
        end)
      end,
      desc = 'Get Devdocs',
    },
    {
      '<leader>hd',
      mode = 'n',
      '<cmd>DevDocs delete<cr>',
      desc = 'Delete Devdoc',
    },

    {
      '<leader>hg',
      mode = 'n',
      function()
        local devdocs = require 'devdocs'
        local installedDocs = devdocs.GetInstalledDocs()
        vim.ui.select(installedDocs, {}, function(selected)
          if not selected then
            return
          end
          local docDir = devdocs.GetDocDir(selected)
          -- prettify the filename as you wish
          Snacks.picker.files {
            cwd = docDir,
            win = {
              input = {
                keys = {
                  ['<CR>'] = {
                    'open_in_glow',
                    desc = 'Open in glow',
                    mode = { 'n', 'i' },
                  },
                },
              },
            },
            actions = {
              ['open_in_glow'] = function(picker)
                local selected_doc = picker:current()._path
                picker:close()
                Snacks.terminal { 'glow', '--pager', selected_doc }
              end,
            },
          }
        end)
      end,
      desc = 'Open Devdocs in Glow',
    },
  },
  opts = {
    ensure_installed = {
      -- 'go',
      'html',
      'dom',
      'http',
      'css',
      'python~3.9',
      'javascript',
      'angularjs~1.8',
      'bash',
      'rust',
      -- some docs such as lua require version number along with the language name
      -- check `DevDocs install` to view the actual names of the docs
      'lua~5.1',
      -- "openjdk~21"
    },
  },
}
