-- TODO: ui of a buffer to display

local M = {}

local function format_as_table(lines)
	if #lines == 0 then
		return {}
	end
	local grid = {}
	local col_widths = {}
	local num_cols = 0
	for _, line in ipairs(lines) do
		local cells = {}
		for cell in string.gmatch(line, "([^,]+)") do
			table.insert(cells, cell:match("^%s*(.-)%s*$"))
		end

		if #cells > 0 then
			if num_cols == 0 then
				num_cols = #cells
				for i = 1, num_cols do
					col_widths[i] = 0
				end
			end

			for i = 1, num_cols do
				local cell_data = cells[i] or ""
				col_widths[i] = math.max(col_widths[i], #cell_data)
			end
			table.insert(grid, cells)
		end
	end

	if num_cols == 0 then
		return lines
	end

	local formatted_lines = {}
	local header_sep = "|"
	local row_format = "|"

	for i = 1, num_cols do
		local width = col_widths[i]
		row_format = row_format .. " %-" .. width .. "s |"
		header_sep = header_sep .. string.rep("-", width + 2) .. "|"
	end

	for i, row in ipairs(grid) do
		local normalized_row = {}
		for j = 1, num_cols do
			table.insert(normalized_row, row[j] or "")
		end

		table.insert(formatted_lines, string.format(row_format, unpack(normalized_row)))

		if i == 1 then
			table.insert(formatted_lines, header_sep)
		end
	end

	return formatted_lines
end

function M.open_float(lines, format_type)
	local formatted_lines = lines

	if format_type == "table" then
		formatted_lines = format_as_table(lines)
	end

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, formatted_lines)

	local width = vim.api.nvim_get_option_value("columns", {})
	local height = vim.api.nvim_get_option_value("lines", {})
	local win_width = math.floor(width * 0.8)
	local win_height = math.floor(height * 0.8)
	local row = math.floor((height - win_height) / 2)
	local col = math.floor((width - win_width) / 2)

	local opts = {
		relative = "editor",
		width = win_width,
		height = win_height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	}

	local win = vim.api.nvim_open_win(buf, true, opts)

	if format_type == "table" then
		vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
	else
		vim.api.nvim_buf_set_option(buf, "filetype", "text")
	end
	vim.api.nvim_buf_set_option(buf, "buftype", "nofile")

	vim.wo[win].number = false
	vim.wo[win].relativenumber = false
	vim.wo[win].cursorline = false
	vim.wo[win].signcolumn = "no"
end

return M
