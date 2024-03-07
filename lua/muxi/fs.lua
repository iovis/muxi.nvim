local M = {}

function M.cwd()
  return assert(vim.loop.cwd(), "[muxi] ERROR: no current directory")
end

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

---@param path string
---@return table<string, Mark[]>
function M.read_stored_sessions(path)
  local data = read_file_sync(path)
  if not data then
    return {}
  end

  return vim.json.decode(vim.trim(data), {
    luanil = { object = true, array = true },
  }) --[[@as table]]
end

function M.write_file_sync(path, data)
  local fd = assert(vim.loop.fs_open(path, "w", 438))

  assert(vim.loop.fs_write(fd, data))
  assert(vim.loop.fs_close(fd))
end

return M
