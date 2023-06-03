local M = {}

local muxi = require("muxi")

function M.delete_key(selected)
  for _, item in ipairs(selected) do
    local key = item:match("%[(.-)%]")
    muxi.delete(key)
  end
end

return M
