local M = {}

---Is character upper case?
---@param char string
---@return boolean
function M.is_upper(char)
  return char:match("%u")
end

---Get one character from user
---@return string|nil
function M.get_char()
  local ok, char = pcall(vim.fn.getcharstr)

  -- Terminate if couldn't get input (like with <C-c>) or it is `<Esc>`
  if not ok or char == "\27" then
    return
  end

  return char
end

return M
