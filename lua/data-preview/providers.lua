-- TODO: simple backend to handle data preview
-- implement head() file logic and get_metadata() logic of a parquet file
-- get the inspect command 'parquet-tools inspect filepath' result, extract the information from that result then display with my own ui
local M = {}

local data_command_providers = {
	parquet = function(filepath)
		if vim.fn.executable("parquet-tools") == 1 then
			return { "sh", "-c", "parquet-tools csv '" .. filepath .. "' | head -n 21" }
		else
			return nil, "there is no parquet-tools"
		end
	end,
}

local stats_command_providers = {
	parquet = function(filepath)
		if vim.fn.executable("parquet-tools") == 1 then
			return { "parquet-tools", "inspect", filepath }
		else
			return nil, "there is no parquet-tools"
		end
	end,
}

function M.get_command(filepath)
	local ext = vim.fn.fnamemodify(filepath, ":e")
	local provider_func = data_command_providers[ext]

	if provider_func then
		local cmd, err_msg = provider_func(filepath)
		return cmd, err_msg
	else
		return nil, "This extension will be supported soon :) ... " .. ext
	end
end

function M.get_stats_command(filepath)
	local ext = vim.fn.fnamemodify(filepath, ":e")
	local provider_func = stats_command_providers[ext]

	if provider_func then
		local cmd, err_msg = provider_func(filepath)
		return cmd, err_msg
	else
		return nil, "This extension will be supported soon :) ... " .. ext
	end
end

return M
