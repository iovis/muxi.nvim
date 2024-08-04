---@class MuxiFzfRow
---@field key string
---@field mark MuxiMark
---@field filename string for `fzf_lua.make_entry.lcol`
---@field lnum number for `fzf_lua.make_entry.lcol`
---@field col number for `fzf_lua.make_entry.lcol`
local MuxiFzfRow = {}

---Initialize a new MuxiFzfRow
---@param key string
---@param mark MuxiMark
---@return MuxiFzfRow
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
