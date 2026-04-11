local M = {}

local function get_config()
  local url = os.getenv 'GITLAB_URL'
  local token = os.getenv 'GITLAB_TOKEN'
  if not url or not token then
    vim.notify('GITLAB_URL or GITLAB_TOKEN not found in environment', vim.log.levels.ERROR)
    return nil
  end
  -- Strip trailing slash
  url = url:gsub('/$', '')
  return { url = url, token = token }
end

local function get_project_id()
  local handle = io.popen 'git remote get-url origin'
  if not handle then
    return nil
  end
  local result = handle:read '*a'
  handle:close()

  -- Handle both SSH and HTTPS
  -- git@gitlab.com:org/repo.git -> org/repo
  -- https://gitlab.com/org/repo.git -> org/repo
  local path = result:match '[:/]([^/]+/[^/%.]+)%.git' or result:match '[:/]([^/]+/[^/%.]+)'
  if path then
    return path:gsub('/', '%%2F')
  end
  return nil
end

local function request(endpoint, method, body)
  local config = get_config()
  if not config then
    return nil
  end
  local project_id = get_project_id()
  if not project_id then
    vim.notify('Could not determine project ID from git remote', vim.log.levels.ERROR)
    return nil
  end

  local url = string.format('%s/api/v4/projects/%s/%s', config.url, project_id, endpoint)
  local curl = require 'plenary.curl'

  local params = {
    headers = {
      ['PRIVATE-TOKEN'] = config.token,
    },
  }

  if body then
    params.body = vim.fn.json_encode(body)
    params.headers['Content-Type'] = 'application/json'
  end

  local res
  if method == 'POST' then
    res = curl.post(url, params)
  else
    res = curl.get(url, params)
  end

  if res.status ~= 200 and res.status ~= 201 then
    vim.notify('GitLab API error: ' .. res.status .. '\n' .. res.body, vim.log.levels.ERROR)
    return nil
  end

  return vim.fn.json_decode(res.body)
end

local note_metadata = {}

local function jump_to_note()
  local line = vim.fn.line '.'
  local data = note_metadata[line]

  if data and data.path and data.line then
    -- Find the window on the left (the one that isn't the current one)
    local cur_win = vim.api.nvim_get_current_win()
    local wins = vim.api.nvim_list_wins()
    local target_win = nil

    for _, win in ipairs(wins) do
      if win ~= cur_win then
        target_win = win
        break
      end
    end

    if not target_win then
      vim.cmd 'vsplit'
      target_win = vim.api.nvim_get_current_win()
      vim.api.nvim_set_current_win(cur_win)
    end

    vim.api.nvim_set_current_win(target_win)
    vim.cmd('edit ' .. data.path)
    vim.api.nvim_win_set_cursor(target_win, { data.line, 0 })
    vim.cmd 'normal! zz'
  end
end

local current_mr_iid = nil

local function render_dashboard(mr_iid)
  current_mr_iid = mr_iid
  local mr = request('merge_requests/' .. mr_iid)
  if not mr then
    return
  end

  local drafts = request('merge_requests/' .. mr_iid .. '/draft_notes') or {}
  local notes = request('merge_requests/' .. mr_iid .. '/notes') or {}

  local buf_name = 'MR Review: ' .. mr_iid
  local existing_buf = nil
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(b)
    if name:match(buf_name .. '$') then
      existing_buf = b
      break
    end
  end

  local buf
  if existing_buf then
    buf = existing_buf
    -- Check if it's already visible in a window
    local win = vim.fn.bufwinid(buf)
    if win == -1 then
      vim.cmd 'botright vnew'
      vim.api.nvim_win_set_buf(0, buf)
    end
  else
    vim.cmd 'botright vnew'
    buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_name(buf, buf_name)
  end

  vim.api.nvim_buf_set_option(buf, 'modifiable', true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {}) -- Clear buffer

  vim.opt_local.buftype = 'nofile'
  vim.opt_local.bufhidden = 'hide' -- Changed from wipe to prevent buffer name issues on refresh
  vim.opt_local.swapfile = false
  vim.opt_local.filetype = 'markdown'
  vim.opt_local.wrap = true
  vim.opt_local.number = false
  vim.opt_local.relativenumber = false
  vim.opt_local.signcolumn = 'no'

  local lines = {
    '# [' .. mr.title .. '](' .. mr.web_url .. ')',
    '`' .. mr.source_branch .. ' → ' .. mr.target_branch .. '` **@' .. mr.author.username .. '**',
    '',
    '---',
    '',
  }

  -- Split description by newline to avoid E5108
  if mr.description then
    for l in mr.description:gsub('\r', ''):gmatch '([^\n]*)\n?' do
      table.insert(lines, l)
    end
  end

  table.insert(lines, '')
  table.insert(lines, '---')
  table.insert(lines, '')

  local pending_marks = {}

  local function add_note_to_lines(note_list, title)
    table.insert(lines, '## ' .. title)
    table.insert(lines, '')

    local has_content = false
    for _, n in ipairs(note_list) do
      if not n.system then
        has_content = true
        local start_line = #lines + 1

        local author_name = 'Unknown'
        local author_username = 'unknown'
        if n.author then
          author_name = n.author.name
          author_username = n.author.username
        end

        table.insert(lines, string.format('### %s (@%s)', author_name, author_username))

        local meta = nil
        if n.position and n.position.new_path and n.position.new_line then
          table.insert(
            lines,
            string.format('> File: %s:%s', n.position.new_path, n.position.new_line)
          )
          meta = { path = n.position.new_path, line = n.position.new_line }
        end

        table.insert(lines, '')
        -- Draft Notes use 'note', Regular Notes use 'body'
        local body = n.note or n.body or ''
        for l in body:gsub('\r', ''):gmatch '([^\n]*)\n?' do
          table.insert(lines, l)
        end

        -- Remove the last empty string if the body ended with a newline
        if lines[#lines] == '' and body:sub(-1) == '\n' then
          table.remove(lines)
        end
        table.insert(lines, '')

        -- Add metadata for jumping
        if meta then
          table.insert(pending_marks, { start_line = start_line, end_line = #lines, meta = meta })
        end
      end
    end

    if not has_content then
      table.insert(lines, '_None_')
      table.insert(lines, '')
    end
  end

  -- Clear old metadata
  note_metadata = {}

  add_note_to_lines(drafts, 'Draft Notes')
  add_note_to_lines(notes, 'Discussions')

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Apply pending metadata
  for _, mark in ipairs(pending_marks) do
    for i = mark.start_line, mark.end_line do
      note_metadata[i] = mark.meta
    end
  end

  vim.keymap.set('n', '<CR>', jump_to_note, { buffer = buf, silent = true })
  vim.opt_local.modifiable = false
end

function M.review_mr()
  local mrs = request 'merge_requests?state=opened'
  if not mrs then
    return
  end

  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local conf = require('telescope.config').values
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'

  pickers
    .new({}, {
      prompt_title = 'Open Merge Requests',
      finder = finders.new_table {
        results = mrs,
        entry_maker = function(entry)
          return {
            value = entry,
            display = string.format('!%s: %s (@%s)', entry.iid, entry.title, entry.author.username),
            ordinal = entry.title .. ' ' .. entry.iid,
          }
        end,
      },
      sorter = conf.generic_sorter {},
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          local mr_summary = selection.value

          -- Fetch full MR details to get source_branch if missing
          local mr = request('merge_requests/' .. mr_summary.iid)
          if not mr or not mr.source_branch then
            vim.notify(
              'Could not fetch MR details or source_branch is missing',
              vim.log.levels.ERROR
            )
            return
          end

          vim.notify('Checking out ' .. mr.source_branch .. '...')

          vim.fn.system('git fetch origin ' .. mr.source_branch)
          local out = vim.fn.system('git checkout ' .. mr.source_branch)
          if vim.v.shell_error ~= 0 then
            vim.notify('Git error: ' .. out, vim.log.levels.ERROR)
            return
          end

          -- Call existing Review command if it exists
          if vim.fn.exists ':ReviewSimple' == 2 then
            vim.cmd 'ReviewSimple'
          end

          render_dashboard(mr.iid)
        end)
        return true
      end,
    })
    :find()
end

function M.create_draft_note(is_visual)
  if not current_mr_iid then
    vim.notify('No active MR review. Run :ReviewMR first.', vim.log.levels.ERROR)
    return
  end

  local mr = request('merge_requests/' .. current_mr_iid)
  if not mr then
    return
  end

  local file_path = vim.fn.expand '%:.'
  local start_line, end_line
  if is_visual then
    start_line = vim.fn.line 'v'
    end_line = vim.fn.line '.'
    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end
  else
    start_line = vim.fn.line '.'
    end_line = start_line
  end

  -- Create a temporary buffer for the note
  vim.cmd 'split'
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, buf)
  vim.api.nvim_buf_set_name(buf, 'GitLab Note Entry')
  vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  -- We use a regular buffer instead of scratch (buftype='') to allow :w to trigger autocommands
  -- but we intercept the write with BufWriteCmd to prevent actual file creation.
  vim.api.nvim_buf_set_option(buf, 'buftype', 'acwrite')

  vim.notify 'Enter note and :wq to send'

  -- Map the send action to buffer close/write
  vim.api.nvim_create_autocmd('BufWriteCmd', {
    buffer = buf,
    callback = function()
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local input = table.concat(lines, '\n'):gsub('^%s*(.-)%s*$', '%1')

      if input == '' then
        vim.notify('Note is empty, discarding.', vim.log.levels.WARN)
        vim.api.nvim_buf_set_option(buf, 'modified', false)
        vim.cmd 'close'
        return
      end

      vim.notify 'Sending draft note...'

      local body = {
        note = input,
        position = {
          base_sha = mr.diff_refs.base_sha,
          start_sha = mr.diff_refs.start_sha,
          head_sha = mr.diff_refs.head_sha,
          position_type = 'text',
          new_path = file_path,
          old_path = file_path,
          new_line = end_line,
        },
      }

      -- Send asynchronously
      vim.schedule(function()
        local res = request('merge_requests/' .. current_mr_iid .. '/draft_notes', 'POST', body)
        if res then
          vim.notify 'Draft note created successfully.'
          -- Refresh dashboard if it exists
          local wins = vim.api.nvim_list_wins()
          for _, win in ipairs(wins) do
            local win_buf = vim.api.nvim_win_get_buf(win)
            local name = vim.api.nvim_buf_get_name(win_buf)
            if name:match('MR Review: ' .. current_mr_iid) then
              vim.api.nvim_win_call(win, function()
                render_dashboard(current_mr_iid)
              end)
              break
            end
          end
        end
      end)

      vim.api.nvim_buf_set_option(buf, 'modified', false)
      vim.cmd 'close'
    end,
  })
end

return M
