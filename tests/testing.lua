local M = {}

local root = vim.env.MUXI_TEST_REPO or vim.fn.getcwd()
local tempdirs = {}

function M.new_spec(opts)
  opts = opts or {}

  local spec = {
    tests = {},
    before_each = opts.before_each or M.before_each,
    after_each = opts.after_each or M.after_each,
  }

  function spec.test(name, fn)
    spec.tests[#spec.tests + 1] = {
      name = name,
      fn = fn,
    }
  end

  return spec
end

function M.assert_eq(actual, expected)
  if vim.deep_equal(actual, expected) then
    return
  end

  error(
    table.concat({
      "assert_eq failed",
      "",
      "expected:",
      vim.inspect(expected),
      "",
      "actual:",
      vim.inspect(actual),
    }, "\n"),
    2
  )
end

local function reset_muxi_modules()
  local names = {}

  for name, _ in pairs(package.loaded) do
    if name == "muxi" or name:match("^muxi%.") then
      names[#names + 1] = name
    end
  end

  for _, name in ipairs(names) do
    package.loaded[name] = nil
  end
end

local function reset_editor()
  ---@diagnostic disable-next-line: param-type-mismatch
  pcall(vim.cmd, "silent! %bwipeout!")
  pcall(vim.api.nvim_del_augroup_by_name, "muxi")
  pcall(vim.api.nvim_del_augroup_by_name, "muxi_marks")
end

function M.new_project()
  local cwd = vim.fn.tempname()
  assert(vim.fn.mkdir(cwd, "p") == 1, "failed to create temp project")
  assert(vim.uv.chdir(cwd), "failed to chdir to temp project")

  tempdirs[#tempdirs + 1] = cwd

  return {
    cwd = cwd,
    store = cwd .. "/muxi.json",
  }
end

function M.write_file(path, lines)
  assert(vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p") == 1, "failed to create parent directory")
  assert(vim.fn.writefile(lines, path) == 0, "failed to write file")
end

function M.write_json(path, value)
  assert(vim.fn.writefile({ vim.json.encode(value) }, path) == 0, "failed to write json")
end

function M.read_json(path)
  return vim.json.decode(table.concat(vim.fn.readfile(path), "\n"), {
    luanil = {
      object = true,
      array = true,
    },
  })
end

function M.setup_muxi(env, opts)
  reset_muxi_modules()

  local muxi = require("muxi")
  muxi.setup(vim.tbl_deep_extend("force", {
    path = env.store,
  }, opts or {}))

  return muxi
end

function M.edit_file(path, lines)
  M.write_file(path, lines)
  vim.cmd.edit(path)
end

function M.wait_for(fn, message)
  assert(vim.wait(1000, fn, 10), message or "timed out")
end

function M.extmarks(muxi)
  return vim.api.nvim_buf_get_extmarks(0, muxi.config.namespace, 0, -1, {
    details = true,
  })
end

function M.only_extmark(muxi)
  local marks = M.extmarks(muxi)
  M.assert_eq(#marks, 1)
  return marks[1]
end

function M.before_each()
  reset_editor()
  reset_muxi_modules()
  assert(vim.uv.chdir(root), "failed to return to repo root")
end

function M.after_each()
  reset_editor()
  reset_muxi_modules()
  assert(vim.uv.chdir(root), "failed to return to repo root")

  for _, dir in ipairs(tempdirs) do
    pcall(vim.fn.delete, dir, "rf")
  end

  tempdirs = {}
end

return M
