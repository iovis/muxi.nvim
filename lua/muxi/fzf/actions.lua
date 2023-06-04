local M = {}

local muxi = require("muxi")

---Extracts a key from an FZF line
---
---Example: "[j] *  lua/muxi/fzf/init.lua"
---
---@param item string FZF returned
---@return string
local function extract_key_from(item)
  return item:match("%[(.-)%]")
end

function M.delete_key(selected)
  for _, item in ipairs(selected) do
    local key = extract_key_from(item)
    muxi.delete(key)
  end
end

function M.toggle_go_to_cursor(_)
  muxi.config.go_to_cursor = not muxi.config.go_to_cursor
end

function M.rename_key(selected)
  local old_key = extract_key_from(selected[1])
  local mark = muxi.marks[old_key]

  vim.ui.input({ prompt = "New key> " }, function(input)
    local new_key = vim.trim(input or "")

    if vim.fn.empty(new_key) == 1 then
      return
    end

    if muxi.marks[new_key] then
      -- If key is already in use, switch it with the old one
      muxi.marks[old_key] = muxi.marks[new_key]
    else
      -- Otherwise, remove the old mark
      muxi.marks[old_key] = nil
    end

    muxi.marks[new_key] = mark
  end)
end

return M
