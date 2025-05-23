local M = {}

local MuxiFzfRow = require("muxi.fzf.marks.row")
local actions = require("muxi.fzf.marks.actions")
local fzf_lua = require("fzf-lua")
local muxi = require("muxi")

---@class muxi.fzf.marks.Opts
M.default_opts = {
  prompt = "muxi> ",
  file_icons = true,
  color_icons = true,
  git_icons = true,
  fzf_opts = { ["--multi"] = true },
  previewer = "builtin",
  _actions = function()
    -- Inherit current file actions (overridable by the user)
    return fzf_lua.config.globals.actions.files
  end,
  actions = {
    ["ctrl-g"] = { fn = actions.toggle_go_to_cursor, reload = true },
    ["ctrl-r"] = { fn = actions.rename_key, reload = true },
    ["ctrl-x"] = { fn = actions.delete_key, reload = true },
  },
  -- actions listed below will be converted to fzf's 'reload'
  reload_actions = {
    [actions.delete_key] = true,
    [actions.rename_key] = true,
    [actions.toggle_go_to_cursor] = true,
  },
}

-- stylua: ignore
local fzf_header_labels = {
  ("<%s> to %s"):format(
    fzf_lua.utils.ansi_codes.yellow("ctrl-x"),
    fzf_lua.utils.ansi_codes.red("delete")
  ),
  ("<%s> to %s"):format(
    fzf_lua.utils.ansi_codes.yellow("ctrl-g"),
    fzf_lua.utils.ansi_codes.red("toggle cursor")
  ),
  ("<%s> to %s"):format(
    fzf_lua.utils.ansi_codes.yellow("ctrl-r"),
    fzf_lua.utils.ansi_codes.red("rename")
  ),
}

---Show muxi marks in fzf-lua
---@param opts? muxi.fzf.marks.Opts
function M.cmd(opts)
  if vim.tbl_isempty(muxi.marks) then
    vim.notify("[muxi] no marks for this session", vim.log.levels.WARN)
    return
  end

  opts = fzf_lua.config.normalize_opts(opts, M.default_opts)

  ----Help
  -- Register custom labels for help menu
  fzf_lua.config.set_action_helpstr(actions.delete_key, "muxi-delete-key")
  fzf_lua.config.set_action_helpstr(actions.rename_key, "muxi-rename-key")
  fzf_lua.config.set_action_helpstr(actions.toggle_go_to_cursor, "muxi-toggle-cursor")

  -- FZF header (legend)
  if opts.fzf_opts["--header"] == nil then
    local header = (":: %s"):format(table.concat(fzf_header_labels, " | "))
    opts.fzf_opts["--header"] = header
  end

  ----Git status
  opts.fn_preprocess = function(o)
    return fzf_lua.make_entry.preprocess(o)
  end

  ----Reload without flickering
  opts.__fn_reload = function(_)
    return muxi:to_fzf_marks_list(opts)
  end

  -- build the "reload" cmd and remove '-- {+}' from the initial cmd
  local reload = fzf_lua.shell.reload_action_cmd(opts, "{+}")
  local contents = reload:gsub("%-%-%s+{%+}$", "")
  opts.__reload_cmd = reload

  ----Yield to fzf-lua
  fzf_lua.fzf_exec(contents, opts)
end

---Convert muxi marks to an fzf list (monkey patch)
---@param opts muxi.fzf.marks.Opts
---@return string[]
function muxi:to_fzf_marks_list(opts)
  ---@type muxi.fzf.Row[]
  local entries = {}

  -- Make a list of muxi marks parseable by fzf
  for key, mark in pairs(self.marks) do
    table.insert(entries, MuxiFzfRow:new(key, mark))
  end

  -- Sort entries by mark key
  table.sort(entries, function(a, b)
    return a.key < b.key
  end)

  -- Let fzf-lua do its magic with formatting
  return vim.tbl_map(function(entry)
    local filename = entry.filename

    -- If `go_to_cursor` is enabled, keep info about location
    if self.config.go_to_cursor then
      filename = fzf_lua.make_entry.lcol(entry, opts)
    end

    local file_entry = fzf_lua.make_entry.file(filename, opts)
    local key = fzf_lua.utils.ansi_codes.yellow(entry.key)
    return ("[%s] %s"):format(key, file_entry)
  end, entries)
end

return M
