-- Experimental
local M = {}
local muxi = require("muxi")
local util = require("muxi.util")

---Muxi superbinding
---If ASCII uppercase => save mark
---else
---  if visual
---    => go to mark in the same file
---  else
---    => go to mark
---@param opts? muxi.go_to.Opts
function M.run(opts)
  local mode = vim.fn.strtrans(vim.fn.mode()):lower():gsub("%W", "")

  if mode == "v" then
    local bufnr = vim.api.nvim_get_current_buf()
    local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":.")
    local marks = muxi.marked_files[file] or {}

    vim.iter(marks):each(function(mark)
      vim.api.nvim_buf_set_extmark(bufnr, muxi.config.visual_namespace, mark.pos[1] - 1, mark.pos[2], {
        strict = false,
        hl_mode = "combine",
        virt_text_pos = "overlay",
        virt_text = {
          { mark.key, "MuxiVirtualText" },
        },
      })
    end)
  end

  local char = util.get_char()

  vim.api.nvim_buf_clear_namespace(0, muxi.config.visual_namespace, 0, -1)

  if not char then
    return
  end

  -- If uppercase, set mark
  if util.is_upper(char) then
    local key = char:lower()

    if muxi.add(key) then
      vim.notify("[muxi] added current file to " .. key)
    end

    return
  end

  -- If lowercase, go to mark
  if mode == "v" then
    local mark = muxi.marks[char]
    local current_file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")

    if not mark then
      vim.notify("[muxi] no mark found for " .. char)
      return
    elseif current_file ~= mark.file then
      vim.notify("[muxi] mark points to a different file (" .. mark.file .. ")")
      return
    end

    local cursor_ok, _ = pcall(vim.api.nvim_win_set_cursor, 0, mark.pos)
    if not cursor_ok then
      vim.notify("[muxi] position doesn't exist anymore! { " .. vim.iter(mark.pos):join(", ") .. " }")
    end
  else
    muxi.go_to(char, opts)
  end
end

---Delete mark superbinding
function M.quick_delete()
  local char = util.get_char()

  if not char then
    return
  end

  muxi.delete(char)

  vim.notify("[muxi] deleted mark " .. char)
end

---Show marks in quickfix list
function M.qf()
  local marks = vim
    .iter(muxi.marks)
    :map(function(key, mark)
      return {
        filename = mark.file,
        lnum = mark.pos[1],
        col = mark.pos[2],
        text = key,
        user_data = key,
      }
    end)
    :totable()

  -- sort by filename and line number
  table.sort(marks, function(a, b)
    if a.filename ~= b.filename then
      return a.filename < b.filename
    end

    return a.lnum < b.lnum
  end)

  vim.fn.setqflist({}, "r", {
    title = "muxi marks",
    items = marks,
  })

  vim.cmd("botright copen")
end

---Show an interactive popup to edit your marks
function M.edit()
  -- Serialize muxi marks into a pretty array of strings
  local marks_table = vim.split(vim.inspect(muxi.marks), "\n")

  -- Make a popup window
  local bufnr = vim.api.nvim_create_buf(false, true)
  local width = math.floor(vim.o.columns / 2)
  local height = math.floor(vim.o.lines / 2)

  vim.api.nvim_open_win(bufnr, true, {
    relative = "editor",
    width = width,
    height = height,
    row = 10,
    col = width - math.floor(width / 2) - 6,
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

      vim.notify("[muxi] updated")
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
    vim.notify("[muxi] no marks for this session!")
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
    vim.notify("[muxi] no marks for this session!")
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
