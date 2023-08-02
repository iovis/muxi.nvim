local M = {}

local muxi = require("muxi")
local fs = require("muxi.fs")

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
