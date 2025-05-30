local M = {}

local actions = require("muxi.fzf.sessions.actions")
local fs = require("muxi.fs")
local fzf_lua = require("fzf-lua")
local muxi = require("muxi")

---@class muxi.fzf.session_manager.Opts
M.default_opts = {
  prompt = "muxi sessions> ",
  fzf_opts = { ["--multi"] = true },
  preview = "eza -la --git --group-directories-first --icons --color=always {1}",
  actions = {
    ["enter"] = actions.open_in_tmux_window,
    ["ctrl-x"] = { fn = actions.delete_session, reload = true },
  },
  reload_actions = {
    [actions.delete_session] = true,
  },
}

-- stylua: ignore
local fzf_header_labels = {
  ("<%s> to %s"):format(
    fzf_lua.utils.ansi_codes.yellow("ctrl-x"),
    fzf_lua.utils.ansi_codes.red("delete")
  ),
}

---Manage muxi sessions
---@param opts? muxi.fzf.session_manager.Opts
function M.cmd(opts)
  opts = fzf_lua.config.normalize_opts(opts, M.default_opts)

  ----Help
  -- Register custom labels for help menu
  fzf_lua.config.set_action_helpstr(actions.open_in_tmux_window, "muxi-open-in-tmux-window")
  fzf_lua.config.set_action_helpstr(actions.delete_session, "muxi-delete-session")

  -- FZF header (legend)
  if opts.fzf_opts["--header"] == nil then
    local header_labels = table.concat(fzf_header_labels, " | ")
    local current_session_label = fzf_lua.utils.ansi_codes.yellow("(current)")
    local header = (":: %s\n%s %s"):format(header_labels, fs.cwd(), current_session_label)

    opts.fzf_opts["--header"] = header
  end

  ----Reload without flickering
  opts.__fn_reload = function(_)
    return muxi:to_fzf_sessions_list()
  end

  -- build the "reload" cmd and remove '-- {+}' from the initial cmd
  local reload = fzf_lua.shell.reload_action_cmd(opts, "{+}")
  local contents = reload:gsub("%-%-%s+{%+}$", "")
  opts.__reload_cmd = reload

  ----Yield to fzf-lua
  fzf_lua.fzf_exec(contents, opts)
end

---Convert muxi marks to an fzf list (monkey patch)
---@return string[]
function muxi:to_fzf_sessions_list()
  -- TODO: ---@type muxi.fzf.Row[]
  local entries = fs.read_stored_sessions(self.config.path) or {}
  local cwd = fs.cwd()

  local sessions = {}
  for path, _ in pairs(entries) do
    if path ~= cwd then
      -- Dim if it doesn't exist anymore
      if not vim.uv.fs_stat(path) then
        path = fzf_lua.utils.ansi_codes.grey(path)
      end

      table.insert(sessions, path)
    end
  end

  table.sort(sessions)

  return sessions
end

return M
