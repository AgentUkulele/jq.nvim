local M = {}

local cmd = require("jq.cmd")
local ui = require("jq.ui")
local utils = require("jq.utils")

local with = require("plenary.context_manager").with
local open = require("plenary.context_manager").open

M.setup = function()
	if not cmd.has_cmd("jq") then
		local msg = "JQ not accessible from PATH"
		vim.notify_once(msg, vim.log.levels.ERROR, { title = "jq.nvim" })
		error(msg)
	end

	vim.api.nvim_create_user_command("JqOpen", function(event)
		local text
		if #event.fargs > 0 then
			local path = event.fargs[1]
			with(open(path), function(reader)
				text = { reader:read() }
			end)
		else
			text = utils.get_highlighted_region()
		end
		ui.open(text)
	end, { range = true, nargs = "?", complete = "file" })

	vim.api.nvim_create_user_command("JqClose", function()
		ui.close()
	end, {})
end

return M
