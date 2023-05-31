---@class MuxiMarkRow
---@field key string
---@field mark Mark
local MuxiMarkRow = {}

---Initialize a new MarkRow
---@param key string
---@param mark Mark
---@return MuxiMarkRow
function MuxiMarkRow:new(key, mark)
  local instance = {
    key = key,
    mark = mark,
  }

  self.__index = self

  ---@diagnostic disable-next-line: redefined-local
  self.__tostring = function(self)
    return ("[%s] %s:%d"):format(self.key, self.mark.file, self.mark.pos[1])
  end

  return setmetatable(instance, self)
end

return MuxiMarkRow
