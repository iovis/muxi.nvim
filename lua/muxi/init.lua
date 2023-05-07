local fs = require("muxi.fs")

---@class Mark
---@field file string
---@field pos number[]

---@class Muxi
---@field sessions table<string, Mark[]>
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
		if not m.sessions[m.cwd] then
			m.sessions[m.cwd] = {}
		end

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

		-- Clean project if empty
		if vim.tbl_isempty(m.sessions[m.cwd]) then
			m.sessions[m.cwd] = nil
		end
	end)
end

--TODO: move out
local function get_current_marks_for_selection()
	local muxi_marks = muxi.sessions[muxi.cwd] or {}
	local marks = {}

	for key, value in pairs(muxi_marks) do
		table.insert(marks, { key = key, file = value.file, pos = value.pos })
	end

	table.sort(marks, function(a, b)
		return a.key < b.key
	end)

	return marks
end

function muxi.delete_prompt()
	local marks = get_current_marks_for_selection()

	if vim.tbl_isempty(marks) then
		vim.notify("No marks for this session!")
		return
	end

	vim.ui.select(marks, {
		prompt = "Select mark to delete: ",
		format_item = function(mark)
			return string.format("[%s]: %s:%d:%d", mark.key, mark.file, mark.pos[1], mark.pos[2])
		end,
	}, function(mark)
		muxi.delete(mark.key)
		vim.notify(string.format("[%s]: %s:%d:%d", mark.key, mark.file, mark.pos[1], mark.pos[2]))
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

	-- TODO: Check if file still exists?
	vim.cmd.edit(mark.file)

	local cursor_ok, _ = pcall(vim.api.nvim_win_set_cursor, 0, mark.pos)
	if not cursor_ok then
		vim.notify("[muxi] position doesn't exist anymore!")
	end
end

function muxi.go_to_prompt()
	local marks = get_current_marks_for_selection()

	if vim.tbl_isempty(marks) then
		vim.notify("No marks for this session!")
		return
	end

	vim.ui.select(marks, {
		prompt = "muxi: ",
		format_item = function(mark)
			return string.format("[%s]: %s:%d:%d", mark.key, mark.file, mark.pos[1], mark.pos[2])
		end,
	}, function(mark)
		muxi.go_to(mark.key)
	end)
end

---Clear current project
function muxi.clear_all()
	muxi:sync(function(m)
		m.sessions[m.cwd] = nil
	end)
end

---Delete muxi storage (clear all sessions)
function muxi.nuke()
	vim.fn.delete(muxi.config.path)
end

--TODO: move out
---@param str string
local function is_empty(str)
	return vim.fn.empty(str) == 1
end

function muxi:init()
	local cwd = vim.loop.cwd()
	if not cwd then
		vim.notify("[muxi] ERROR: no current directory", vim.log.levels.ERROR)
		return
	end

	self.cwd = cwd
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
