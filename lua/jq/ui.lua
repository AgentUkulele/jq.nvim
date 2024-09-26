local M = {}

local cmd = require("jq.cmd")
local utils = require("jq.utils")

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
	local json_in = utils.create_window("jq-input", "json", 100)
	vim.api.nvim_buf_set_lines(json_in.buf_id, -1, -1, true, json)
	M._bufs["json_in_buf"] = json_in.buf_id

	-- Input Buffer
	vim.cmd("botright split")
	local input = utils.create_window("jq-filter", "jq", 10)
	M._bufs["input_buf"] = input.buf_id

	-- JSON Output
	vim.cmd("botright vsplit")
	local json_out = utils.create_window("jq-output", "json", 100)
	M._bufs["json_out_buf"] = json_out.buf_id

	vim.api.nvim_create_augroup("jq.nvim", { clear = true })

	vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
		group = "jq.nvim",
		buffer = input.buf_id,
		callback = function(_)
			local filter = table.concat(vim.api.nvim_buf_get_lines(input.buf_id, 0, -1, false))
			local json_highlighted = table.concat(vim.api.nvim_buf_get_lines(json_in.buf_id, 0, -1, false))
			local res = cmd.run_cmd("jq", json_highlighted, filter)
			vim.api.nvim_buf_set_lines(json_out.buf_id, 0, -1, true, res)
		end,
	})

	for _, buf in ipairs({ json_in.buf_id, input.buf_id, json_out.buf_id }) do
		vim.api.nvim_create_autocmd({ "WinClosed" }, {
			group = "jq.nvim",
			buffer = buf,
			callback = function()
				M.close()
			end,
		})
	end

	vim.api.nvim_set_current_win(input.win_id)
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
