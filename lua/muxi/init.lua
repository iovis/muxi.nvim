local fs = require("muxi.fs")

---@class Mark
---@field file string
---@field pos number[]

---@class Muxi
---@field marks Mark[]
local muxi = {}

---@class MuxiConfig
muxi.config = {
  path = vim.fn.stdpath("data") .. "/muxi.json",
  go_to_cursor = true,
}

---@param opts MuxiConfig
function muxi.setup(opts)
  opts = opts or {}

  muxi.config = vim.tbl_deep_extend("force", muxi.config, opts)

  muxi:init()
end

---Add the current file to a key
---@param key string
function muxi.add(key)
  muxi:sync(function(m)
    m.marks[key] = {
      file = vim.fn.expand("%"),
      pos = vim.api.nvim_win_get_cursor(0),
    }
  end)
end

---@class GoToOpts
---@field go_to_cursor? boolean

---Go to session
---@param key string
---@param opts? GoToOpts
function muxi.go_to(key, opts)
  local mark = muxi.marks[key]

  if not mark then
    vim.notify("No mark found for " .. key)
    return
  end

  -- TODO: Check if file still exists? It'll open a new buffer otherwise
  vim.cmd.edit(mark.file)

  -- Navigate to cursor
  local config = vim.tbl_deep_extend("force", muxi.config, opts or {})

  if config.go_to_cursor then
    local cursor_ok, _ = pcall(vim.api.nvim_win_set_cursor, 0, mark.pos)
    if not cursor_ok then
      vim.notify("[muxi] position doesn't exist anymore!")
    end
  end

  -- Center cursor
  vim.cmd("norm! zz")
end

---Delete mark
---@param key string
function muxi.delete(key)
  muxi:sync(function(m)
    m.marks[key] = nil
  end)
end

---Clear current project
function muxi.clear_all()
  muxi:sync(function(m)
    m.marks = {}
  end)
end

---Delete muxi storage (clear all sessions)
function muxi.nuke()
  vim.fn.delete(muxi.config.path)
end

function muxi:init()
  local cwd = fs.cwd()
  self.marks = fs.read_stored_sessions(self.config.path)[cwd] or {}
end

-- TODO: Could be async
function muxi:save()
  -- Read all the sessions to avoid sync issues
  local cwd = fs.cwd()
  local sessions = fs.read_stored_sessions(self.config.path)

  -- We're the source of truth for the current session
  self.marks = self.marks or {}
  if vim.tbl_isempty(self.marks) then
    sessions[cwd] = nil -- clean up project if no marks
  else
    sessions[cwd] = self.marks
  end

  local json = vim.json.encode(sessions)
  fs.write_file_sync(self.config.path, json)
end

---Run a callback that syncs the store
---@param fn fun(muxi: Muxi): nil
function muxi:sync(fn)
  fn(self)

  self:save()
end

return muxi
