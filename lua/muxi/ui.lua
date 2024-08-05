-- Experimental
local M = {}
local muxi = require("muxi")
local util = require("muxi.util")

---Muxi superbinding
---If ASCII uppercase => save mark
---else => go to mark
---@param opts? MuxiGoToOpts
function M.run(opts)
  local char = util.get_char()

  if not char then
    return
  end

  -- If uppercase, set mark
  if util.is_upper(char) then
    local key = char:lower()

    muxi.add(key)
    vim.notify("Added current file to " .. key)

    return
  end

  -- If lowercase, go to mark
  muxi.go_to(char, opts)
end

---Delete mark superbinding
function M.quick_delete()
  local char = util.get_char()

  if not char then
    return
  end

  muxi.delete(char)

  vim.notify("Deleted mark " .. char)
end

---Show an interactive popup to edit your marks
function M.edit()
  -- Serialize muxi marks into a pretty array of strings
  local marks_table = vim.split(vim.inspect(muxi.marks), "\n")

  -- Make a popup window
  local bufnr = vim.api.nvim_create_buf(false, true)
  local half_screen_width = math.floor(vim.o.columns / 2)
  local half_screen_height = math.floor(vim.o.lines / 2)
  local width = half_screen_width
  local height = math.max(math.min(half_screen_height, #marks_table), 10)

  vim.api.nvim_open_win(bufnr, true, {
    relative = "editor",
    width = width,
    height = height,
    row = 10,
    col = half_screen_width - math.floor(width / 2) - 6,
    style = "minimal",
    border = "rounded",
    title = " muxi ",
    noautocmd = true,
  })

  -- Set the contents to muxi table and the filetype to lua
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, marks_table)
  vim.bo[bufnr].filetype = "lua"

  -- Save new marks when leaving the popup
  local augroup_muxi = vim.api.nvim_create_augroup("muxi_marks", { clear = true })
  vim.api.nvim_create_autocmd("BufLeave", {
    desc = "Save muxi table",
    group = augroup_muxi,
    buffer = bufnr,
    callback = function()
      local new_marks_string = vim.trim(table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n"))

      if vim.fn.empty(new_marks_string) == 1 then
        new_marks_string = "{}"
      end

      local new_marks = assert(vim.fn.luaeval(new_marks_string))

      muxi:sync(function(m)
        m.marks = new_marks
      end)

      vim.notify("muxi updated")
    end,
  })

  -- Map [q] to read the changes and close the popup
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = bufnr })
end

local function get_current_marks_for_selection()
  local marks = {}

  for key, value in pairs(muxi.marks) do
    table.insert(marks, { key = key, file = value.file, pos = value.pos })
  end

  table.sort(marks, function(a, b)
    return a.key < b.key
  end)

  return marks
end

---Use vim.ui.select to delete a mark
function M.delete_prompt()
  local marks = get_current_marks_for_selection()

  if vim.tbl_isempty(marks) then
    vim.notify("No marks for this session!")
    return
  end

  vim.ui.select(marks, {
    prompt = "Select mark to delete: ",
    format_item = function(mark)
      return string.format("[%s]: %s:%d:%d", mark.key, mark.file, mark.pos[1], mark.pos[2])
    end,
  }, function(mark)
    muxi.delete(mark.key)
  end)
end

---Use vim.ui.select to go to a mark
function M.go_to_prompt()
  local marks = get_current_marks_for_selection()

  if vim.tbl_isempty(marks) then
    vim.notify("No marks for this session!")
    return
  end

  vim.ui.select(marks, {
    prompt = "muxi: ",
    format_item = function(mark)
      return string.format("[%s]: %s:%d:%d", mark.key, mark.file, mark.pos[1], mark.pos[2])
    end,
  }, function(mark)
    muxi.go_to(mark.key)
  end)
end

return M
