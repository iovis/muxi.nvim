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

---Add the current file to a key
---@param key string
function muxi.add(key)
	muxi:sync(function(m)
		m.sessions[m.cwd][key] = {
			file = vim.fn.expand("%"),
			pos = vim.api.nvim_win_get_cursor(0),
		}
	end)
end

---Delete mark
---@param key string
function muxi.delete(key)
	muxi:sync(function(m)
		m.sessions[m.cwd][key] = nil
	end)
end

---Go to session
---@param key string
function muxi.go_to(key)
	local mark = muxi.sessions[muxi.cwd][key]

	if not mark then
		vim.notify("No mark found for " .. key)
		return
	end

	vim.cmd.edit(mark.file)
	vim.api.nvim_win_set_cursor(0, mark.pos)
end

---Clear current project
function muxi.clear_all()
	muxi:sync(function(m)
		m.sessions[m.cwd] = nil
	end)
end

---Clear all projects
function muxi.nuke()
	vim.fn.delete(muxi.config.path)
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
		-- TODO: Error handling
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

function muxi:save()
	local json = vim.json.encode(muxi.sessions)

	fs.write_file_sync(self.config.path, json)
end

---Run a callback that syncs the store
---@param fn fun(muxi: Muxi): nil
function muxi:sync(fn)
	-- Re-source to avoid synchronization issues
	self:init()
	fn(self)
	self:save()
end

return muxi
