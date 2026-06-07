local t = require("testing")

local M = t.new_spec()
local assert_eq = t.assert_eq
local test = M.test

test("loads stored project marks and jumps to saved cursor", function()
  local env = t.new_project()
  t.write_file(env.cwd .. "/alpha.txt", { "one", "two", "three" })
  t.write_json(env.store, {
    [env.cwd] = {
      a = {
        file = "alpha.txt",
        key = "a",
        pos = { 2, 1 },
      },
    },
  })

  local muxi = t.setup_muxi(env)

  assert_eq(muxi.marks.a.file, "alpha.txt")

  muxi.go_to("a")

  assert_eq(vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t"), "alpha.txt")
  assert_eq(vim.api.nvim_win_get_cursor(0), { 2, 1 })
  assert_eq(t.only_extmark(muxi)[2], 1)
end)

test("adds a mark, persists it, and renders its sign", function()
  local env = t.new_project()
  local muxi = t.setup_muxi(env)

  t.edit_file("alpha.txt", { "one", "two", "three" })
  vim.api.nvim_win_set_cursor(0, { 2, 1 })

  assert(muxi.add("a"))
  t.wait_for(function()
    return muxi.marks.a ~= nil
  end, "mark was not added")

  assert_eq(muxi.marks.a, {
    file = "alpha.txt",
    key = "a",
    pos = { 2, 1 },
  })

  local sessions = t.read_json(env.store)
  assert_eq(sessions[env.cwd].a.pos, { 2, 1 })

  local mark = t.only_extmark(muxi)
  assert_eq(mark[2], 1)
  assert_eq(mark[3], 0)
  assert_eq(vim.trim(mark[4].sign_text), "a")
end)

test("deletes a mark from storage and clears its sign", function()
  local env = t.new_project()
  local muxi = t.setup_muxi(env)

  t.edit_file("alpha.txt", { "one", "two", "three" })
  vim.api.nvim_win_set_cursor(0, { 2, 0 })

  assert(muxi.add("a"))
  t.wait_for(function()
    return #t.extmarks(muxi) == 1
  end, "sign was not rendered")

  muxi.delete("a")
  t.wait_for(function()
    return muxi.marks.a == nil and #t.extmarks(muxi) == 0
  end, "mark was not deleted")

  local sessions = t.read_json(env.store)
  assert_eq(sessions[env.cwd], nil)
end)

test("TextChanged re-renders the sign at the saved line", function()
  local env = t.new_project()
  local muxi = t.setup_muxi(env)

  t.edit_file("alpha.txt", { "one", "two", "three" })
  vim.api.nvim_win_set_cursor(0, { 2, 0 })

  assert(muxi.add("a"))
  t.wait_for(function()
    return #t.extmarks(muxi) == 1
  end, "sign was not rendered")

  assert_eq(t.only_extmark(muxi)[2], 1)

  vim.api.nvim_buf_set_lines(0, 0, 0, false, { "zero" })
  assert_eq(t.only_extmark(muxi)[2], 2)

  vim.api.nvim_exec_autocmds("TextChanged", { buffer = 0 })
  assert_eq(t.only_extmark(muxi)[2], 1)
  assert_eq(muxi.marks.a.pos, { 2, 0 })
end)

return M
