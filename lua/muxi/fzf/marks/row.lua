---@class muxi.fzf.Row
---@field key muxi.key
---@field mark muxi.Mark
---@field filename muxi.file for `fzf_lua.make_entry.lcol`
---@field lnum number for `fzf_lua.make_entry.lcol`
---@field col number for `fzf_lua.make_entry.lcol`
local MuxiFzfRow = {}

---Initialize a new muxi.fzf.Row
---@param key muxi.key
---@param mark muxi.Mark
---@return muxi.fzf.Row
function MuxiFzfRow:new(key, mark)
  local instance = {
    key = key,
    mark = mark,
    -- The following are to satisfy the interface of `fzf_lua.make_entry.lcol`
    filename = mark.file,
    lnum = mark.pos[1],
    col = mark.pos[2] + 1, -- 1-based instead of 0-based
    -- text = "", -- put text after column number in fzf-lua
  }

  self.__index = self

  ---@diagnostic disable-next-line: redefined-local
  self.__tostring = function(self)
    return ("[%s] %s:%d"):format(self.key, self.mark.file, self.mark.pos[1])
  end

  return setmetatable(instance, self)
end

return MuxiFzfRow
