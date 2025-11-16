-- TODO: main file

local M = {}

local ui = require("data-preview.ui")
local providers = require("data-preview.providers")

function M.preview()
	local filepath = vim.fn.expand("%:p")
	if filepath == "" then
		vim.notify("There is no file ...", vim.log.levels.ERROR, { title = "DataPreview" })
		return
	end
	local cmd, err_msg = providers.get_command(filepath)
	if err_msg then
		vim.notify(err_msg, vim.log.levels.ERROR, { title = "DataPreview" })
		return
	end
	if not cmd then
		local ext = vim.fn.fnamemodify(filepath, ":e")
		vim.notify(
			"This extension will be supported soon .... :) " .. ext,
			vim.log.levels.ERROR,
			{ title = "DataPreview" }
		)
		return
	end

	local output_lines = {}
	local stderr_lines = {}

	vim.fn.jobstart(cmd, {
		on_stdout = function(_, data)
			for _, line in ipairs(data) do
				if line ~= "" then
					table.insert(output_lines, line)
				end
			end
		end,
		on_stderr = function(_, data)
			for _, line in ipairs(data) do
				if line ~= "" then
					table.insert(stderr_lines, line)
				end
			end
		end,
		on_exit = function(_, code)
			vim.schedule(function()
				if code == 0 then
					if #output_lines == 0 then
						ui.open_float({ "[Command ran successfully, but produced no output]" }, nil)
					else
						ui.open_float(output_lines, "table")
					end
				else
					table.insert(stderr_lines, 1, "ERROR: Command failed (code " .. code .. "):")
					ui.open_float(stderr_lines, nil)
				end
			end)
		end,
	})
end

return M
