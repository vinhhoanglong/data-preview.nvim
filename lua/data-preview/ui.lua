-- lua/data-preview/ui.lua
-- TODO: ui of a buffer to display
-- CHỈ chịu trách nhiệm vẽ cửa sổ nổi

local M = {}

-- XÓA: format_as_table, format_as_stats, get_spark_type, generate_spark_schema
-- Tất cả chúng đã được chuyển đến 'formatter.lua'

-- Hàm open_float giờ đây đơn giản hơn
-- Nó nhận 'filetype' thay vì 'format_type'
function M.open_float(lines, filetype, title)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	local width = vim.api.nvim_get_option_value("columns", {})
	local height = vim.api.nvim_get_option_value("lines", {})
	local win_width = math.floor(width * 0.8)
	local win_height = math.floor(height * 0.8)
	local row = math.floor((height - win_height) / 2)
	local col = math.floor((width - win_width) / 2)

	local float_title = title or "Data Preview"

	local opts = {
		relative = "editor",
		width = win_width,
		height = win_height,
		row = row,
		col = col,
		style = "minimal",
		border = "double",
		title = " " .. float_title .. " ",
		title_pos = "center",
	}

	local win = vim.api.nvim_open_win(buf, true, opts)

	-- Sử dụng biến 'filetype' được truyền vào
	vim.api.nvim_buf_set_option(buf, "filetype", filetype or "text")
	vim.api.nvim_buf_set_option(buf, "buftype", "nofile")

	vim.wo[win].number = false
	vim.wo[win].relativenumber = false
	vim.wo[win].cursorline = false
	vim.wo[win].signcolumn = "no"
end

return M
