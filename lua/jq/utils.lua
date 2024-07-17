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

return M
