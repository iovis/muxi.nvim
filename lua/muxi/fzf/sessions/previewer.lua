local builtin = require("fzf-lua.previewer.builtin")
local fs = require("muxi.fs")
local muxi = require("muxi")

local SessionPreviewer = builtin.base:extend()

function SessionPreviewer:new(o, opts, fzf_win)
  SessionPreviewer.super.new(self, o, opts, fzf_win)
  setmetatable(self, SessionPreviewer)

  self.sessions = fs.read_stored_sessions(muxi.config.path) or {}

  return self
end

function SessionPreviewer:populate_preview_buf(entry_str)
  local tmpbuf = self:get_tmp_buffer()

  -- Serialize muxi session into a pretty array of strings
  local session = vim.split(vim.inspect(self.sessions[entry_str]), "\n")

  vim.api.nvim_buf_set_lines(tmpbuf, 0, -1, false, session)
  vim.bo[tmpbuf].filetype = "lua"

  self:set_preview_buf(tmpbuf)
  self.win:update_preview_scrollbar()
end

-- Disable line numbering and word wrap
function SessionPreviewer:gen_winopts()
  local new_winopts = {
    cursorline = false,
    number = false,
    wrap = false,
  }

  return vim.tbl_extend("force", self.winopts, new_winopts)
end

return SessionPreviewer
