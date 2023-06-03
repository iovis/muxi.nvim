-- Integration with https://github.com/ibhagwan/fzf-lua
local fzf_installed, fzf_lua = pcall(require, "fzf-lua")
if not fzf_installed then
  vim.notify("fzf-lua not found!", vim.log.levels.ERROR)
  return
end

local M = {}
local muxi = require("muxi")
local actions = require("muxi.fzf.actions")
local MuxiFzfRow = require("muxi.fzf.row")

local default_opts = {
  prompt = "muxi> ",
  file_icons = true,
  color_icons = true,
  git_icons = true, -- TODO: not working
  previewer = "builtin",
  actions = vim.tbl_deep_extend("force", fzf_lua.defaults.actions.files, {
    ["ctrl-x"] = {
      actions.delete_key,
      fzf_lua.actions.resume,
    },
  }),
  fzf_opts = {},
}

function M.marks(opts)
  if vim.tbl_isempty(muxi.marks) then
    vim.notify("No marks for this session", vim.log.levels.WARN)
    return
  end

  opts = vim.tbl_deep_extend("force", default_opts, opts or {})

  -- Register `actions.delete_key` for help's label
  fzf_lua.config.set_action_helpstr(actions.delete_key, "delete-muxi-key")

  -- FZF header (legend)
  if opts.fzf_opts["--header"] == nil then
    local key = fzf_lua.utils.ansi_codes.yellow("ctrl-x")
    local action = fzf_lua.utils.ansi_codes.red("delete")
    opts.fzf_opts["--header"] = vim.fn.shellescape((":: <%s> to %s"):format(key, action))
  end

  -- Generate rows for fzf
  local contents = function(fzf_cb)
    ---@type MuxiFzfRow[]
    local entries = {}

    -- Make a list of marks parseable by fzf
    for key, mark in pairs(muxi.marks) do
      table.insert(entries, MuxiFzfRow:new(key, mark))
    end

    -- Sort entries by mark key
    table.sort(entries, function(a, b)
      return a.key < b.key
    end)

    -- Send entries to fzf
    for _, entry in ipairs(entries) do
      local filename = entry.filename

      -- If `go_to_cursor` is enabled, keep info about location
      if muxi.config.go_to_cursor then
        filename = fzf_lua.make_entry.lcol(entry, opts)
      end

      local file_entry = fzf_lua.make_entry.file(filename, opts)
      local key = fzf_lua.utils.ansi_codes.yellow(entry.key)
      local row = ("[%s] %s"):format(key, file_entry)

      fzf_cb(row)
    end

    fzf_cb(nil)
  end

  fzf_lua.fzf_exec(contents, opts)
end

return M