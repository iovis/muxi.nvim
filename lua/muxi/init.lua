local fs = require("muxi.fs")

---@alias MuxiFile string
---@alias MuxiKey string

---@class MuxiMark
---@field file MuxiFile
---@field pos number[]

---@class Muxi
---@field marks table<MuxiKey, MuxiMark>
---@field marked_files table<MuxiFile, MuxiKey[]>
---@field config MuxiConfig
---@field to_fzf_marks_list? fun(Muxi, MuxiFzfMarksOpts): string[]
---@field to_fzf_sessions_list? fun(Muxi): string[]
local muxi = {}

---@class MuxiConfig
---@field path string
---@field go_to_cursor boolean
muxi.config = {
  path = vim.fn.stdpath("data") .. "/muxi.json",
  go_to_cursor = true,
}

---@param opts MuxiConfig
function muxi.setup(opts)
  muxi.config = vim.tbl_deep_extend("force", muxi.config, opts or {})
  muxi:init()

  -- Re exports
  muxi.ui = require("muxi.ui")

  local fzf_installed, _ = pcall(require, "fzf-lua")
  if fzf_installed then
    muxi.fzf = require("muxi.fzf")
  end
end

---Add the current file to a key
---@param key string
---@return boolean success?
function muxi.add(key)
  local file = vim.fn.expand("%")

  if vim.fn.empty(file) == 1 then
    vim.notify("[muxi] no file", vim.log.levels.ERROR)
    return false
  end

  muxi:sync(function(m)
    m.marks[key] = {
      file = file,
      pos = vim.api.nvim_win_get_cursor(0),
    }
  end)

  return true
end

---@class MuxiGoToOpts
---@field go_to_cursor? boolean

---Go to session
---@param key string
---@param opts? MuxiGoToOpts
function muxi.go_to(key, opts)
  local mark = muxi.marks[key]

  if not mark then
    vim.notify("No mark found for " .. key)
    return
  end

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

---@private
function muxi:init()
  local cwd = fs.cwd()
  self.marks = fs.read_stored_sessions(self.config.path)[cwd] or {}
  self:marks_reverse_lookup()
end

-- TODO: Could be async
---@private
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

---Create a reverse lookup of Muxi marks
---@private
function muxi:marks_reverse_lookup()
  local files = {}

  for key, mark in pairs(self.marks) do
    if files[mark.file] then
      table.insert(files[mark.file], key)
    else
      files[mark.file] = { key }
    end
  end

  self.marked_files = files
end

---Run a callback that syncs the store
---@private
---@param fn fun(muxi: Muxi): nil
function muxi:sync(fn)
  vim.schedule(function()
    fn(self)
    self:save()
    self:marks_reverse_lookup()
  end)
end

return muxi
