local M = {}

local muxi = require("muxi")
local fs = require("muxi.fs")

function M.open_in_tmux_window(selected)
  -- Open each of them in a new tmux window
  for _, pwd in ipairs(selected) do
    local title = vim.fn.fnamemodify(pwd, ":t")

    vim.system({
      "tmux",
      "new-window",
      "-Sn",
      title,
      "-c",
      pwd,
      "nvim -S Session.vim",
    })
  end
end

function M.delete_session(selected)
  local sessions = fs.read_stored_sessions(muxi.config.path) or {}

  -- Delete selected sessions
  for _, pwd in ipairs(selected) do
    sessions[pwd] = nil
  end

  local json = vim.json.encode(sessions)
  fs.write_file_sync(muxi.config.path, json)
end

return M
