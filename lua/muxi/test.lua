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

	---- Init muxi
	print("---- Init muxi")
	local muxi = require("muxi")

	muxi.setup({})

	vim.print("muxi: ", muxi.sessions)

	-----------------------------------------
	if true then
		vim.cmd("R! messages")
		vim.cmd("se ft=lua")
		return
	end

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
end

return M
