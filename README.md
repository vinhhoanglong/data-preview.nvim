# data-preview.nvim
A simple Neovim plugin for data engineers and anyone who works with Parquet (and Avro soon).
This plugin provides a "quick look" command to instantly preview the contents or metadata of large data files in a floating window, right from your editor.
## Features
- Preview Data: Shows the first 20 rows of .parquet in a beautifully formatted table.
- Preview Stats: Shows file metadata for .parquet files (schema, row count, column stats) and .avro files (schema).
- Lightweight: Acts as a simple wrapper around external tools.
- Lazy-Loaded: Loads instantly only when you run one of its commands.
## Dependencies
## Installation
Instal using [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua 
return {
  'vinvolve/data-preview.nvim',
  cmd = { "DataPreview", "DataPreviewStats" },
  config = function()
    local data_preview = require("data-preview")
    vim.api.nvim_create_user_command(
      "DataPreview",
      data_preview.preview,
      {
        nargs = 0,
        desc = "Preview data file (Parquet, Avro)",
      }
    )
    vim.api.nvim_create_user_command(
      "DataPreviewStats",
      data_preview.preview_stats,
      {
        nargs = 0,
        desc = "Preview data file statistics (min, max, nulls, etc.)",
      }
    )
  end,
}
```
