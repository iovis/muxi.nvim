local M = {}

local function write_line(line)
  io.stdout:write(line .. "\n")
  io.stdout:flush()
end

local colors = {
  bold = "\27[1m",
  green = "\27[32m",
  red = "\27[31m",
  reset = "\27[0m",
}

local function color(text, code)
  if vim.env.NO_COLOR then
    return text
  end

  return code .. text .. colors.reset
end

local function bold(text)
  return color(text, colors.bold)
end

local function green(text)
  return color(text, colors.bold .. colors.green)
end

local function red(text)
  return color(text, colors.bold .. colors.red)
end

local function pass_icon()
  return green("✔")
end

local function fail_icon()
  return red("✗")
end

local function pluralize(count, singular, plural)
  return count == 1 and singular or plural
end

local function split_traceback(err)
  local message, stack = tostring(err):gsub("\t", "  "):match("^(.-)\nstack traceback:\n(.*)$")

  return message or tostring(err), stack
end

local function relevant_stack_lines(stack)
  if not stack then
    return {}
  end

  local lines = {}

  for _, line in ipairs(vim.split(stack, "\n", { plain = true, trimempty = true })) do
    line = vim.trim(line)

    if
      not line:find("[C]: in function 'xpcall'", 1, true)
      and not line:find("[C]: in function 'error'", 1, true)
      and not line:find("/tests/run.lua", 1, true)
      and not line:find('[string ":lua"]', 1, true)
    then
      lines[#lines + 1] = line
    end
  end

  return lines
end

local function write_failure(failure)
  local message, stack = split_traceback(failure.err)
  local stack_lines = message:find("assert_eq failed", 1, true) and {} or relevant_stack_lines(stack)

  write_line("")
  write_line(("%s %s"):format(fail_icon(), bold(failure.name)))

  for _, line in ipairs(vim.split(message, "\n", { plain = true })) do
    if line == "expected:" then
      write_line("  " .. green(line))
    elseif line == "actual:" then
      write_line("  " .. red(line))
    else
      write_line(line == "" and "" or "  " .. line)
    end
  end

  if #stack_lines > 0 then
    write_line("")
    write_line("  " .. bold("stack:"))

    for _, line in ipairs(stack_lines) do
      write_line("    " .. line)
    end
  end
end

local function load_tests(root)
  local files = vim.fn.glob(root .. "/tests/*_spec.lua", false, true)
  local tests = {}

  table.sort(files)

  for _, file in ipairs(files) do
    local spec = dofile(file)

    for _, test_case in ipairs(spec.tests or {}) do
      tests[#tests + 1] = {
        name = test_case.name,
        fn = test_case.fn,
        before_each = test_case.before_each or spec.before_each,
        after_each = test_case.after_each or spec.after_each,
      }
    end
  end

  return tests
end

function M.run()
  local root = vim.env.MUXI_TEST_REPO or vim.fn.getcwd()
  local tests = load_tests(root)
  local failures = {}

  for _, test_case in ipairs(tests) do
    if test_case.before_each then
      test_case.before_each()
    end

    local ok, err = xpcall(test_case.fn, debug.traceback)
    local cleanup_ok, cleanup_err = true, nil

    if test_case.after_each then
      cleanup_ok, cleanup_err = xpcall(test_case.after_each, debug.traceback)
    end

    if ok and cleanup_ok then
      write_line(("%s %s"):format(pass_icon(), test_case.name))
    else
      write_line(("%s %s"):format(fail_icon(), test_case.name))

      failures[#failures + 1] = {
        name = test_case.name,
        err = ok and cleanup_err or err,
      }
    end
  end

  local summary = ("%d %s, %d %s"):format(
    #tests,
    pluralize(#tests, "test", "tests"),
    #failures,
    pluralize(#failures, "failure", "failures")
  )
  local styled_summary = #failures == 0 and green(summary) or red(summary)

  write_line("")
  write_line(styled_summary)

  if #failures > 0 then
    write_line("")
    write_line(bold("Failures:"))

    for _, failure in ipairs(failures) do
      write_failure(failure)
    end

    write_line("")
    vim.cmd("cquit 1")
  end
end

return M
