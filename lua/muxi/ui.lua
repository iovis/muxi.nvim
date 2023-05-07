-- Experimental
local M = {}
local muxi = require("muxi")

local function get_current_marks_for_selection()
	local marks = {}

	for key, value in pairs(muxi.marks) do
		table.insert(marks, { key = key, file = value.file, pos = value.pos })
	end

	table.sort(marks, function(a, b)
		return a.key < b.key
	end)

	return marks
end

function M.delete_prompt()
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
	end)
end

function M.go_to_prompt()
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

return M
