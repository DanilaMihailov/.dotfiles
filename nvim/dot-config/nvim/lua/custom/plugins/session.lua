return {
  'rmagatti/auto-session',
  lazy = true,

  init = function()
    local function restore()
      if vim.fn.argc(-1) > 0 then
        return
      end

      -- do not restore session when using kitty scrollback
      if vim.env.KITTY_SCROLLBACK_NVIM == 'true' then
        return
      end

      if vim.bo.ft == 'man' then
        return
      end

      vim.schedule(function()
        require('auto-session').AutoRestoreSession()
      end)
    end

    local lazy_view_win = nil

    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      callback = function()
        local lazy_view = require 'lazy.view'

        if lazy_view.visible() then
          lazy_view_win = lazy_view.view.win
        else
          restore()
        end
      end,
    })

    vim.api.nvim_create_autocmd('WinClosed', {
      callback = function(event)
        if not lazy_view_win or event.match ~= tostring(lazy_view_win) then
          return
        end

        restore()
      end,
    })
  end,
  config = function()
    require('auto-session').setup {
      log_level = 'error',
      pre_save_cmds = { 'NvimTreeClose', 'NeogitClose' },
      session_lens = {
        load_on_setup = false,
      },
    }
  end,
}
