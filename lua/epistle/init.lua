local M = {}
local opts = {}

local default_opts = {
	dir = "$HOME/.local/share/epistle/",
	ext = ".md",
	find_prompt_icon = "",
	daily_note_subdir = "daily"
}

local fio = require("epistle.file_io")

local function get_selection()
	local block = vim.fn.visualmode() == ""
	local s_start = vim.fn.getpos("'<")
	local s_end = vim.fn.getpos("'>")
	local start_row = s_start[2] - 1
	local start_col = s_start[3] - 1
	local end_row = s_end[2] - 1
	local end_col = s_end[3]
	if end_col == 2147483647 then
		end_col = end_col - 1
	end

	local lines = {}
	if block then
		for row = start_row, end_row do
			-- in visual block, we need to grab just the start_col to end_col from each line
			table.insert(lines, vim.api.nvim_buf_get_text(0, row, start_col, row, end_col, {})[1])
		end
	else
		lines = vim.api.nvim_buf_get_text(0, start_row, start_col, end_row, end_col, {})
	end
	return lines
end

function M.setup(user_opts)
	opts = vim.tbl_extend("force", default_opts, user_opts)

	opts.dir = vim.fs.normalize(opts.dir)
	fio.mkdir(opts.dir)

	if opts.ext:sub(1, 1) ~= "." then
		opts.ext = "." .. opts.ext
	end
end

function M.today()
	local file = os.date("%Y-%m-%d") .. opts.ext
	if opts.daily_note_subdir ~= "" then
		file = opts.daily_note_subdir .. "/" .. file
	end
	M.open(file)
end

function M.open(name)
	if not name then
		vim.ui.input({ prompt = "File Name" }, function(input)
			M.open(input)
		end)
	else
		local fn = opts.dir .. name
		fio.mkdir(vim.fs.dirname(fn))
		vim.cmd("e " .. fn)
	end
end

function M.new_from_selection(name)
	if not name then
		vim.ui.input({ prompt = "File Name" }, function(input)
			M.new_from_selection(input)
		end)
		return
	end
	local lines = get_selection()
	local fn = opts.dir .. name
	fio.write_file(fn, vim.fn.join(lines, "\n"))
	vim.cmd("e " .. fn)
end

function M.find()
	local ok, tl = pcall(require, "telescope.builtin")
	if not ok then
		vim.api.nvim_err_writeln("telescope not installed")
		return
	end
	local pt = "Find Notes"
	if opts.find_prompt_icon ~= "" then
		pt = opts.find_prompt_icon .. " " .. pt
	end
	tl.find_files({
		prompt_title = pt,
		path_dispaly = { "smart" },
		cwd = opts.dir
	})
end

return M
