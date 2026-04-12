vim.pack.add { 'https://github.com/nmac427/guess-indent.nvim' }

require('guess-indent').setup {
  override_editorconfig = true, -- Set to true to override settings set by .editorconfig
}
