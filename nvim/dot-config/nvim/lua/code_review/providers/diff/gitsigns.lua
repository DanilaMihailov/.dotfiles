local util = require 'code_review.util'

local M = {}

local function get_gitsigns()
  local ok, gitsigns = pcall(require, 'gitsigns')
  if ok then
    return gitsigns
  end
  return nil
end

function M.apply(session)
  local gitsigns = get_gitsigns()
  if not gitsigns then
    return false
  end

  if session.mode == 'branch' and session.base_sha then
    gitsigns.change_base(session.base_sha, true)
  else
    gitsigns.change_base(nil, true)
  end

  if gitsigns.toggle_signs then
    gitsigns.toggle_signs(true)
  end
  vim.opt.signcolumn = 'yes'

  return true
end

function M.reset()
  local gitsigns = get_gitsigns()
  if not gitsigns then
    return false
  end

  gitsigns.change_base(nil, true)
  if gitsigns.toggle_signs then
    gitsigns.toggle_signs(false)
  end
  vim.opt.signcolumn = 'number'
  util.notify 'Review diff base reset'

  return true
end

return M
