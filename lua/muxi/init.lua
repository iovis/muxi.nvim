local fs = require("muxi.fs")

---@alias muxi.file string
---@alias muxi.key string

---@class muxi.Mark
---@field file muxi.file
---@field key muxi.key
---@field pos number[]

---@class muxi.sign.Options
---@field sign_column boolean
---@field virtual_text boolean

---@class Muxi
---@field marks table<muxi.key, muxi.Mark>
---@field marked_files table<muxi.file, muxi.Mark[]>
---@field config muxi.Config
---@field to_fzf_marks_list? fun(Muxi, muxi.fzf.marks.Opts): string[]
---@field to_fzf_sessions_list? fun(Muxi): string[]
local muxi = {}

vim.api.nvim_set_hl(0, "MuxiSign", { fg = "#ef9f76" })
vim.api.nvim_set_hl(0, "MuxiVirtualText", { fg = "#ef9f76", bold = true })

---@class muxi.Config
---@field namespace number
---@field path string
---@field go_to_cursor boolean
---@field signs muxi.sign.Options?
muxi.config = {
  namespace = vim.api.nvim_create_namespace("muxi"),
  visual_namespace = vim.api.nvim_create_namespace("muxi_visual"),
  path = vim.fn.stdpath("data") .. "/muxi.json",
  go_to_cursor = true,
  signs = {
    sign_column = true,
    virtual_text = false,
  },
}

---@param opts muxi.Config
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
---@param key muxi.key
---@return boolean success?
function muxi.add(key)
  local file = vim.fn.expand("%:.")

  if vim.fn.empty(file) == 1 then
    vim.notify("[muxi] no file", vim.log.levels.ERROR)
    return false
  end

  muxi:sync(function(m)
    m.marks[key] = {
      file = file,
      key = key,
      pos = vim.api.nvim_win_get_cursor(0),
    }
  end)

  return true
end

---@class muxi.go_to.Opts
---@field go_to_cursor? boolean

---Go to session
---@param key muxi.key
---@param opts? muxi.go_to.Opts
function muxi.go_to(key, opts)
  local mark = muxi.marks[key]

  if not mark then
    vim.notify("[muxi] no mark found for " .. key)
    return
  end

  vim.cmd.edit(mark.file)

  -- Navigate to cursor
  local config = vim.tbl_deep_extend("force", muxi.config, opts or {})

  if config.go_to_cursor then
    local cursor_ok, _ = pcall(vim.api.nvim_win_set_cursor, 0, mark.pos)
    if not cursor_ok then
      vim.notify("[muxi] position doesn't exist anymore! { " .. vim.iter(mark.pos):join(", ") .. " }")
    end
  end

  -- Center cursor
  vim.cmd("norm! zz")
end

---Marks for current file
---@return muxi.Mark[]
function muxi.marks_for_current_file()
  return muxi.marked_files[vim.fn.expand("%:.")] or {}
end

---Delete mark
---@param key muxi.key
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

  if self.config.signs then
    self:set_signs()

    local muxi_augroup = vim.api.nvim_create_augroup("muxi", { clear = true })

    vim.api.nvim_create_autocmd("BufRead", {
      desc = "Render muxi marks",
      group = muxi_augroup,
      pattern = "*",
      callback = function(event)
        self:set_buf_signs(event.buf)
      end,
    })
  end
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
    local value = {
      key = key,
      pos = mark.pos,
      file = mark.file,
    }

    if files[mark.file] then
      table.insert(files[mark.file], value)
    else
      files[mark.file] = { value }
    end
  end

  self.marked_files = files
end

---Render signs in all buffers
---@private
function muxi:set_signs()
  vim.iter(vim.api.nvim_list_bufs()):each(function(bufnr)
    self:set_buf_signs(bufnr)
  end)
end

---Render signs in buffer
---@private
---@param bufnr integer
function muxi:set_buf_signs(bufnr)
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    return
  end

  local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":.")
  local marks = self.marked_files[file] or {}

  vim.api.nvim_buf_clear_namespace(bufnr, self.config.namespace, 0, -1)

  vim.iter(marks):each(function(mark)
    local ok, result = pcall(function()
      local opts = {
        hl_mode = "combine",
      }

      if self.config.signs.sign_column then
        opts = vim.tbl_deep_extend("force", opts, {
          sign_text = mark.key:sub(1, 2),
          sign_hl_group = "MuxiSign",
        })
      end

      if self.config.signs.virtual_text then
        opts = vim.tbl_deep_extend("force", opts, {
          virt_text = {
            { "[" .. mark.key .. "]", "MuxiVirtualText" },
          },
        })
      end

      vim.api.nvim_buf_set_extmark(bufnr, self.config.namespace, mark.pos[1] - 1, 0, opts)
    end)

    if not ok and false then
      vim.print(file)
      vim.print(mark)
      vim.notify("[muxi] " .. result --[[@as string]], vim.log.levels.WARN)
    end
  end)
end

---Run a callback that syncs the store
---@param fn fun(muxi: Muxi): nil
function muxi:sync(fn)
  vim.schedule(function()
    fn(self)

    self:save()
    self:marks_reverse_lookup()

    if self.config.signs then
      self:set_signs()
    end
  end)
end

return muxi
