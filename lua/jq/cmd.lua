local M = {}

local job = require("plenary.job")

---@param cmd string Command to check is executable
M.has_cmd = function(cmd)
	return vim.fn.executable(cmd) == 1
end

---@param exe string jq executable name
---@param json string JSON to perform filter on
---@param filter string Filter to apply to JSON
---@return string[] stdout of jq
M.run_cmd = function(exe, json, filter)
	local res = job:new({
		command = exe,
		args = { filter },
		writer = json,
	}):sync()

	return res
end

return M
