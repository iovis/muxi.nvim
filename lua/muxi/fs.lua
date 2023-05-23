local M = {}

-- :h uv_fs_t
local function read_file_sync(path)
  local fd = vim.loop.fs_open(path, "r", 438)
  local data = nil

  if fd then
    local stat = assert(vim.loop.fs_fstat(fd))
    data = assert(vim.loop.fs_read(fd, stat.size, 0)) --[[@as string]]
    assert(vim.loop.fs_close(fd))
  end

  return data
end

function M.write_file_sync(path, data)
  local fd = assert(vim.loop.fs_open(path, "w", 438))

  assert(vim.loop.fs_write(fd, data))
  assert(vim.loop.fs_close(fd))
end

function M.cwd()
  return assert(vim.loop.cwd(), "[muxi] ERROR: no current directory")
end

---@param str string
local function is_empty(str)
  return vim.fn.empty(str) == 1
end

---@param path string
---@return table<string, Mark[]>
function M.read_stored_sessions(path)
  local data = vim.trim(read_file_sync(path))

  if is_empty(data) then
    return {}
  end

  -- TODO: Error handling
  local sessions = vim.json.decode(data, {
    luanil = { object = true, array = true },
  }) --[[@as table]]

  return sessions
end

return M
