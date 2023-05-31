local muxi = require("muxi")
local fzf_builtin_previewer = require("fzf-lua.previewer.builtin")

local MuxiPreviewer = fzf_builtin_previewer.buffer_or_file:extend()

function MuxiPreviewer:new(o, opts, fzf_win)
  MuxiPreviewer.super.new(self, o, opts, fzf_win)
  setmetatable(self, MuxiPreviewer)
  return self
end

function MuxiPreviewer:parse_entry(entry_str)
  local key = entry_str:match("%[(.-)%]")
  local mark = muxi.marks[key]

  return {
    path = mark.file,
    line = mark.pos[1],
    col = mark.pos[2],
  }
end

return MuxiPreviewer
