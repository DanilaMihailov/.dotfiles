vim.pack.add {
  {
    src = 'https://github.com/folke/sidekick.nvim',
    version = vim.version.range '2.x',
  },
}

require('sidekick').setup {
  cli = {
    win = {
      wo = {
        scrolloff = 1,
        winhighlight = 'Normal:Normal,NormalNC:Normal,EndOfBuffer:Normal,SignColumn:Normal',
      },
      split = {
        width = 100,
      },
    },
    tools = {
      codex = {
        cmd = { 'codex', 'resume', '--last' },
      },
    },
    context = {
      diagnostics_line = function(ctx)
        local line_ctx = vim.tbl_extend('force', ctx, {
          range = {
            from = { ctx.row, 0 },
            to = { ctx.row, math.huge },
            kind = 'line',
          },
        })

        return require('sidekick.cli.context.diagnostics').get(line_ctx)
      end,
    },
    prompts = {
      diagnostics_line = 'Can you help me fix only this diagnostics?\n{diagnostics_line}',
    },
  },
}

vim.api.nvim_set_hl(0, 'SidekickChat', { link = 'Normal' })
vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function()
    vim.api.nvim_set_hl(0, 'SidekickChat', { link = 'Normal' })
  end,
})

vim.api.nvim_create_autocmd({ 'TermEnter', 'TextChangedT' }, {
  callback = function(args)
    if vim.bo[args.buf].filetype ~= 'sidekick_terminal' then
      return
    end

    vim.schedule(function()
      local last_line = vim.api.nvim_buf_line_count(args.buf)

      for _, win in ipairs(vim.fn.win_findbuf(args.buf)) do
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_set_cursor(win, { last_line, 0 })
        end
      end
    end)
  end,
})

vim.keymap.set('i', '<tab>', function()
  -- if there is a next edit, jump to it, otherwise apply it if any
  if not require('sidekick').nes_jump_or_apply() then
    return '<Tab>' -- fallback to normal tab
  end
  return ''
end, { expr = true, desc = 'Goto/Apply Next Edit Suggestion' })

vim.keymap.set({ 'n', 't', 'i', 'x' }, '<c-.>', function()
  require('sidekick.cli').focus()
end, { desc = 'Sidekick Focus' })

local function sidekick_open_codex(focus)
  require('sidekick.cli.session').setup()

  local state = require 'sidekick.cli.state'
  local current = state.get({ attached = true, cwd = true, name = 'codex' })[1]

  state.attach(current or {
    installed = vim.fn.executable 'codex' == 1,
    tool = require('sidekick.config').get_tool 'codex',
  }, {
    focus = focus,
    show = true,
  })
end

vim.keymap.set('n', '<leader>aa', function()
  sidekick_open_codex(true)
end, { desc = 'Sidekick Open Codex and Focus' })

vim.keymap.set('n', '<leader>aC', function()
  require('sidekick.cli').select { filter = { installed = true, name = 'codex' }, focus = true }
end, { desc = 'Sidekick Select Codex Session' })

local sidekick_zoomed = false

local function sidekick_submit(focus)
  require('sidekick.cli.state').with(function(state)
    if state.session then
      state.session:submit()
    end
  end, {
    attach = true,
    filter = { installed = true },
    focus = focus,
    show = true,
  })
end

vim.keymap.set('n', '<leader>az', function()
  local width = sidekick_zoomed and 100 or math.floor(vim.o.columns * 0.8)

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.w[win].sidekick_session_id and vim.api.nvim_win_get_config(win).relative == '' then
      vim.api.nvim_win_set_width(win, width)
    end
  end

  sidekick_zoomed = not sidekick_zoomed
end, { desc = 'Sidekick Toggle Zoom' })

vim.keymap.set({ 'n', 'x' }, '<leader>as', function()
  sidekick_submit(false)
end, { desc = 'Sidekick Submit' })

vim.keymap.set({ 'n', 'x' }, '<leader>aS', function()
  sidekick_submit(true)
end, { desc = 'Sidekick Submit and Focus' })

vim.keymap.set({ 'x', 'n' }, '<leader>at', function()
  require('sidekick.cli').send { msg = '{this}', focus = false }
end, { desc = 'Send This' })

vim.keymap.set({ 'x', 'n' }, '<leader>aT', function()
  require('sidekick.cli').send { msg = '{this}', focus = true }
end, { desc = 'Send This and Focus' })

vim.keymap.set('n', '<leader>af', function()
  require('sidekick.cli').send { msg = '{file}', focus = false }
end, { desc = 'Send File' })

vim.keymap.set('n', '<leader>aF', function()
  require('sidekick.cli').send { msg = '{file}', focus = true }
end, { desc = 'Send File and Focus' })

vim.keymap.set('x', '<leader>av', function()
  require('sidekick.cli').send { msg = '{selection}', focus = false }
end, { desc = 'Send Visual Selection' })

vim.keymap.set('x', '<leader>aV', function()
  require('sidekick.cli').send { msg = '{selection}', focus = true }
end, { desc = 'Send Visual Selection and Focus' })

vim.keymap.set({ 'n', 'x' }, '<leader>ap', function()
  require('sidekick.cli').prompt {
    cb = function(_, text)
      if text then
        require('sidekick.cli').send { text = text, focus = false }
      end
    end,
  }
end, { desc = 'Sidekick Select Prompt' })

vim.keymap.set({ 'n', 'x' }, '<leader>aP', function()
  require('sidekick.cli').prompt {
    cb = function(_, text)
      if text then
        require('sidekick.cli').send { text = text, focus = true }
      end
    end,
  }
end, { desc = 'Sidekick Select Prompt and Focus' })
