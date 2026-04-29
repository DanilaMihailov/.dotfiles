local M = {}

function M.notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = 'code-review.nvim' })
end

function M.trim(value)
  local trimmed = (value or ''):gsub('^%s+', ''):gsub('%s+$', '')
  return trimmed
end

function M.repo_root(path)
  local start = path
  if not start or start == '' then
    start = vim.api.nvim_buf_get_name(0)
  end
  if not start or start == '' then
    start = vim.uv.cwd()
  end

  return vim.fs.root(start, '.git') or vim.uv.cwd()
end

function M.relpath(root, path)
  path = vim.fn.fnamemodify(path, ':p')
  root = vim.fn.fnamemodify(root, ':p'):gsub('/$', '')

  local ok, rel = pcall(vim.fs.relpath, root, path)
  if ok and rel then
    return rel
  end

  if path:sub(1, #root + 1) == root .. '/' then
    return path:sub(#root + 2)
  end

  return path
end

function M.joinpath(...)
  return vim.fs.joinpath(...)
end

function M.hash(value)
  local ok, hashed = pcall(vim.fn.sha256, value)
  if ok and hashed and hashed ~= '' then
    return hashed
  end

  return value:gsub('[^%w_.-]', '_')
end

function M.now()
  return os.date '!%Y-%m-%dT%H:%M:%SZ'
end

function M.new_id(prefix)
  return string.format('%s_%s_%s', prefix, os.time(), vim.uv.hrtime())
end

function M.run_git(root, args)
  local cmd = { 'git' }
  vim.list_extend(cmd, args)

  local result = vim.system(cmd, { cwd = root, text = true }):wait()
  return {
    ok = result.code == 0,
    code = result.code,
    stdout = result.stdout or '',
    stderr = result.stderr or '',
  }
end

function M.read_json(path)
  if vim.fn.filereadable(path) == 0 then
    return nil
  end

  local content = table.concat(vim.fn.readfile(path), '\n')
  if content == '' then
    return nil
  end

  local ok, decoded = pcall(vim.json.decode, content)
  if not ok then
    return nil
  end

  return decoded
end

function M.write_json(path, data)
  vim.fn.mkdir(vim.fn.fnamemodify(path, ':h'), 'p')
  vim.fn.writefile({ vim.json.encode(data) }, path)
end

function M.sort_notes(notes)
  table.sort(notes, function(a, b)
    if a.path == b.path then
      return (a.start_line or 0) < (b.start_line or 0)
    end
    return (a.path or '') < (b.path or '')
  end)
end

return M
