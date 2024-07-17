local M = {}

local cmd = require("jq.cmd")

M._open = false
M._bufs = {}

---@param json string[] JSON to put in JSON Input Buffer by default
M.open = function(json)
	if M._open then
		local msg = "Only one instance of jq.nvim can be open at a time!"
		vim.notify_once(msg, vim.log.levels.ERROR, { title = "jq.nvim" })
		return
	end
	M._open = true
	vim.cmd("tabnew")

	-- JSON Input
	local json_in_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(json_in_buf, "jq-input")
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = json_in_buf })
	vim.api.nvim_set_option_value("filetype", "json", { buf = json_in_buf })
	local json_in_win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(json_in_win, json_in_buf)
	vim.api.nvim_buf_set_lines(json_in_buf, -1, -1, true, json)
	M._bufs["json_in_buf"] = json_in_buf

	-- Input Buffer
	vim.cmd("botright split")
	local input_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(input_buf, "jq-filter")
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = input_buf })
	vim.api.nvim_set_option_value("filetype", "jq", { buf = input_buf })
	local input_win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(input_win, input_buf)
	vim.api.nvim_win_set_height(input_win, 10)
	M._bufs["input_buf"] = input_buf

	-- JSON Output
	vim.cmd("botright vsplit")
	local json_out_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(json_out_buf, "jq-output")
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = json_out_buf })
	vim.api.nvim_set_option_value("filetype", "json", { buf = json_out_buf })
	local json_out_win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(json_out_win, json_out_buf)
	M._bufs["json_out_buf"] = json_out_buf

	vim.api.nvim_create_augroup("jq.nvim", { clear = true })

	vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
		group = "jq.nvim",
		buffer = input_buf,
		callback = function(_)
			local filter = table.concat(vim.api.nvim_buf_get_lines(input_buf, 0, -1, false))
			local json = table.concat(vim.api.nvim_buf_get_lines(json_in_buf, 0, -1, false))
			local res = cmd.run_cmd("jq", json, filter)
			vim.api.nvim_buf_set_lines(json_out_buf, 0, -1, true, res)
		end,
	})

	for _, buf in ipairs({ json_in_buf, input_buf, json_out_buf }) do
		vim.api.nvim_create_autocmd({ "WinClosed" }, {
			group = "jq.nvim",
			buffer = buf,
			callback = function()
				M.close()
			end,
		})
	end

	vim.api.nvim_set_current_win(input_win)
end

M.close = function()
	if M._open then
		M._open = false
		for _, v in pairs(M._bufs) do
			vim.api.nvim_buf_delete(v, { force = true })
		end
	end
end

return M
