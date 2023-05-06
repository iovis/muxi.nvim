--[[
Example payload
```json
{
  "/Users/david/.dotfiles": {
    "j": {
      "file": "nvim/.config/nvim/after/plugin/muxi.lua",
      "pos": [3, 5]
    }
  }
}
```
]]
local M = {}

local fs = require("muxi.fs")

function M.test()
	vim.cmd("messages clear")
	-----------------------------------------

	---@param str string
	local function is_empty(str)
		return vim.fn.empty(str) == 1
	end

	---- Init muxi
	print("---- Init muxi")
	local muxi_path = vim.fn.stdpath("data") .. "/muxi.json"

	local data = fs.read_file_sync(muxi_path)
	print("synchronous read", data)

	local muxi = {}
	if not is_empty(data) then
		muxi = vim.json.decode(data, { luanil = { object = true, array = true } }) --[[@as table]]
	end

	vim.print("muxi: ", muxi)

	---- Initialize muxi table for current directory
	print("---- Init current directory")
	local cwd = vim.loop.cwd()

	if not cwd then
		vim.notify("[muxi] ERROR: no current directory", vim.log.levels.ERROR)
		return
	end

	if not muxi[cwd] then
		muxi[cwd] = {}
	end

	-- Seems like lua does references, not copy. Good to know
	local current = muxi[cwd]

	vim.print("muxi: ", muxi)

	---- Save bookmark for current file
	print("---- Save key")
	local key = "j"

	-- muxi[pwd][key] = {
	current[key] = {
		file = vim.fn.expand("%"),
		pos = vim.api.nvim_win_get_cursor(0),
	}

	vim.print("muxi: ", muxi)

	---- Navigating to bookmark
	print("---- Navigating to key")

	local pos = current[key].pos

	vim.print("pos: ", pos)
	vim.api.nvim_win_set_cursor(0, pos)

	---- Cleaning up a bookmark
	if false then
		print("---- Clean up key")
		current[key] = nil

		vim.print("muxi: ", muxi)
	end

	---- Cleaning up a workspace
	print("---- Clean up workspace")

	if vim.tbl_isempty(muxi[cwd]) then
		muxi[cwd] = nil
	end

	vim.print("muxi: ", muxi)

	---- JSON encode the muxi table
	print("---- JSON encode")

	local json = vim.json.encode(muxi)
	vim.print("json: ", json)

	---- Save to file
	print("---- Write to file")
	fs.write_file_sync(muxi_path, json)

	-----------------------------------------
	vim.cmd("R! messages")
	vim.cmd("se ft=lua")
end

return M
