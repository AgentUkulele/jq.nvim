local M = {}

---@return string[] Array of strings representing currently highlgihted text
M.get_highlighted_region = function()
	local vstart = vim.fn.getpos("'<")

	local vend = vim.fn.getpos("'>")

	local line_start = vstart[2]
	local line_end = vend[2]

	local lines = vim.fn.getline(line_start, line_end)

	return lines
end

--- @class JQWindow
--- @field win_id number
--- @field buf_id number

--- @param winname string Name for created window
--- @param ft string Filetype for created buffer
--- @param height number
--- @return JQWindow
M.create_window = function(winname, ft, height)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(buf, winname)
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
	vim.api.nvim_set_option_value("filetype", ft, { buf = buf })
	local input_win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(input_win, buf)
	vim.api.nvim_win_set_height(input_win, height)

	return {
		win_id = input_win,
		buf_id = buf,
	}
end

return M
