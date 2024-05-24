local M = {}

function M.read_file(file_path)
	local uv = vim.loop
	local fd = uv.fs_open(file_path, "r", 438) -- 438 is the octal for 0666
	if not fd then
		vim.api.nvim_err_writeln("Failed to open file: " .. file_path)
		return nil
	end

	local stat = uv.fs_fstat(fd)
	if not stat then
		vim.api.nvim_err_writeln("Failed to stat file: " .. file_path)
		uv.fs_close(fd)
		return nil
	end

	local data = uv.fs_read(fd, stat.size, 0)
	if not data then
		vim.api.nvim_err_writeln("Failed to read file: " .. file_path)
		uv.fs_close(fd)
		return nil
	end

	uv.fs_close(fd)
	return data
end

function M.mkdir(path)
	local uv = vim.loop
	uv.fs_mkdir(path, 448)
end

function M.write_file(file_path, content)
	local uv = vim.loop
	local fd = uv.fs_open(file_path, "w+", 438) -- 438 is the octal for 0666
	if not fd then
		vim.api.nvim_err_writeln("Failed to open file: " .. file_path)
		return false
	end

	local success = uv.fs_write(fd, content, 0)
	if not success then
		vim.api.nvim_err_writeln("Failed to write to file: " .. file_path)
		uv.fs_close(fd)
		return false
	end

	uv.fs_close(fd)
	return true
end

return M
