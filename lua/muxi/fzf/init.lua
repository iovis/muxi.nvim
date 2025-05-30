-- Integration with https://github.com/ibhagwan/fzf-lua
local fzf_installed, _ = pcall(require, "fzf-lua")
if not fzf_installed then
  vim.notify("[muxi] fzf-lua not found!", vim.log.levels.ERROR)
  return
end

local M = {}

M.marks_default_opts = require("muxi.fzf.marks").default_opts
M.marks = require("muxi.fzf.marks").cmd

M.sessions_default_opts = require("muxi.fzf.sessions").default_opts
M.sessions = require("muxi.fzf.sessions").cmd

return M
