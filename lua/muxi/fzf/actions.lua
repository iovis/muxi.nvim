local M = {}

local muxi = require("muxi")

function M.delete_key(selected)
  for _, item in ipairs(selected) do
    local key = item:match("%[(.-)%]")
    muxi.delete(key)
  end
end

function M.toggle_go_to_cursor(_)
  muxi.config.go_to_cursor = not muxi.config.go_to_cursor
end

return M
