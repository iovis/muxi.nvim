local M = {}

-- :h uv_fs_t
-- TODO: May need to make async
function M.read_file_sync(path)
	local fd = vim.loop.fs_open(path, "r", 438)
	local data = nil

	if fd then
		local stat = assert(vim.loop.fs_fstat(fd))
		data = assert(vim.loop.fs_read(fd, stat.size, 0)) --[[@as string]]
		assert(vim.loop.fs_close(fd))
	end

	return data
end

function M.write_file_sync(path, data)
	local fd = assert(vim.loop.fs_open(path, "w", 438))

	assert(vim.loop.fs_write(fd, data))
	assert(vim.loop.fs_close(fd))
end

return M
