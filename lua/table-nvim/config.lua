---@class (exact) TableNvimConfig Configuration of this plugin.
---@field padd_column_separators boolean Insert a space around column separators.
---@field mappings TableNvimMappings Keymappings.

---@class (exact) TableNvimMappings Keymappings used in this plugin.
---@field next string Go to next cell.
---@field prev string Go to previous cell.
---@field insert_row_up string Insert a row above the current row.
---@field insert_row_down string Insert a row below the current row.
---@field insert_column_left string Insert a column to the left of current column.
---@field insert_column_right string Insert a column to the right of current column.
---@field insert_table string Insert a new table.
---@field insert_table_alt string Insert a new table that is not surrounded by pipes.
---@field delete_column string Delete the column under cursor.

---@type TableNvimConfig
local uconf = {
  padd_column_separators = true,   -- Insert a space around column separators.
  mappings = {                     -- All mappings work in Normal and Insert modes.
    next = '<TAB>',                -- Go to next cell.
    prev = '<S-TAB>',              -- Go to previous cell.
    insert_row_up = '<A-k>',       -- Insert a row above the current row.
    insert_row_down = '<A-j>',     -- Insert a row below the current row.
    insert_column_left = '<A-h>',  -- Insert a column to the left of current column.
    insert_column_right = '<A-l>', -- Insert a column to the right of current column.
    insert_table = '<A-t>',        -- Insert a new table.
    insert_table_alt = '<A-S-t>',  -- Insert a new table that is not surrounded by pipes.
    delete_column = '<A-d>',       -- Delete the column under cursor.
  }
}

---Configure the plugin.
---@param config TableNvimConfig
local set_config = function(config)
  uconf = vim.tbl_deep_extend('force', uconf, config)
end

---Returns the current configuration
---@return TableNvimConfig
local get_config = function()
  return uconf
end

return {
  set_config = set_config,
  get_config = get_config
}
