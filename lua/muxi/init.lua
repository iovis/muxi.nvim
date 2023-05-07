local fs = require("muxi.fs")

---@class Muxi
local muxi = {}

----Re-exports
muxi.test = require("muxi.test").test

---@class MuxiConfig
muxi.config = {
	path = vim.fn.stdpath("data") .. "/muxi.json",
}

---@param opts MuxiConfig
function muxi.setup(opts)
	opts = opts or {}

	muxi.config = vim.tbl_deep_extend("force", muxi.config, opts)

  muxi:init()
end

--TODO: move
---@param str string
local function is_empty(str)
	return vim.fn.empty(str) == 1
end

function muxi:init()
	self.sessions = {}

	local data = fs.read_file_sync(self.config.path)

	if not is_empty(data) then
		-- TODO: Should I just keep the current session's data here?
		local stored_sessions = vim.json.decode(data, {
			luanil = { object = true, array = true },
		}) --[[@as table]]

		self.sessions = vim.tbl_deep_extend("force", self.sessions, stored_sessions)
	end

	local cwd = vim.loop.cwd()
	if not cwd then
		vim.notify("[muxi] ERROR: no current directory", vim.log.levels.ERROR)
		return
	end

	self.cwd = cwd

	if not self.sessions[self.cwd] then
		self.sessions[self.cwd] = {}
	end
end

return muxi
