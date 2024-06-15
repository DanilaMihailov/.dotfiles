return {
  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    event = { 'BufRead' },
    cmd = 'IBLToggle',
    opts = {
      -- use IBLToggle to enable/disable when needed
      enabled = false,
      scope = {
        show_start = false,
        show_end = false
      }
    },
    init = function()
      vim.keymap.set('n', '<leader>ti', function()
        vim.cmd 'IBLToggle'
      end, { desc = '[T]oggle [I]ndent Lines' })
    end,
  },
}
