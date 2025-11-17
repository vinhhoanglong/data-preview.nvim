local M = {}

local function get_spark_type(col)
	if col.logical_type then
		if col.logical_type:match("^Timestamp") then
			return "TimestampType()"
		end
		if col.logical_type:match("^Date") then
			return "DateType()"
		end
		if col.logical_type and (col.logical_type:match("String") or col.logical_type:match("UTF8")) then
			return "StringType()"
		end
	end

	local ptype = col.physical_type
	if ptype == "INT64" then
		return "LongType()"
	end
	if ptype == "INT32" then
		return "IntegerType()"
	end
	if ptype == "DOUBLE" then
		return "DoubleType()"
	end
	if ptype == "FLOAT" then
		return "FloatType()"
	end
	if ptype == "BOOLEAN" then
		return "BooleanType()"
	end
	if ptype == "BINARY" or ptype == "BYTE_ARRAY" then
		return "BinaryType()"
	end
	return "StringType()"
end

local function generate_spark_schema(lines)
	local columns = {}
	local current_column = nil
	for _, line in ipairs(lines) do
		local col_name = line:match("^############ Column%((.-)%) ############$")
		local ptype = line:match("^physical_type: (.*)$")
		local ltype = line:match("^logical_type: (.*)$")
		if col_name then
			current_column = { name = col_name, nullable = true }
			table.insert(columns, current_column)
		elseif current_column then
			if ptype then
				current_column.physical_type = ptype:match("^%s*(.-)%s*$")
			elseif ltype then
				current_column.logical_type = ltype:match("^%s*(.-)%s*$")
			end
		end
	end

	local schema_lines = {
		"## Spark Schema (PySpark)",
		"",
		"```python",
		"schema = StructType([",
	}
	for _, col in ipairs(columns) do
		local spark_type = get_spark_type(col)
		table.insert(schema_lines, '    StructField("' .. col.name .. '", ' .. spark_type .. ", True),")
	end
	table.insert(schema_lines, "])")
	table.insert(schema_lines, "```")
	return schema_lines
end

local function format_as_stats(lines)
	local spark_schema_lines = generate_spark_schema(lines)
	local formatted_lines = {}
	local in_code_block = false

	for _, line in ipairs(lines) do
		local header = line:match("^############ (.*) ############$")
		local indented = line:match("^%s+")
		if header then
			if in_code_block then
				table.insert(formatted_lines, "```")
				in_code_block = false
			end
			table.insert(formatted_lines, "")
			table.insert(formatted_lines, "## " .. header)
			table.insert(formatted_lines, "")
		elseif indented then
			if not in_code_block then
				table.insert(formatted_lines, "```")
				in_code_block = true
			end
			table.insert(formatted_lines, line)
		else
			if in_code_block then
				table.insert(formatted_lines, "```")
				in_code_block = false
			end
			table.insert(formatted_lines, line)
		end
	end
	if in_code_block then
		table.insert(formatted_lines, "```")
	end
	table.insert(formatted_lines, "")
	table.insert(formatted_lines, "---")
	table.insert(formatted_lines, "")
	for _, line in ipairs(spark_schema_lines) do
		table.insert(formatted_lines, line)
	end
	return formatted_lines
end

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

function M.format(lines, format_type)
	if format_type == "table" then
		return format_as_table(lines), "markdown"
	elseif format_type == "stats" then
		return format_as_stats(lines), "markdown"
	elseif lines == nil or #lines == 0 then
		return { "[No output]" }, "text"
	else
		-- Mặc định chỉ trả về văn bản thô
		return lines, "text"
	end
end

return M
