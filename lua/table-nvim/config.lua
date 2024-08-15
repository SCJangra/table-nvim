---@class (exact) TableNvimConfig Configuration of this plugin.
---@field padd_column_separators boolean Insert a space around column separators.
---@field mappings TableNvimMappings Keymappings.

---@class (exact) TableNvimMappings Keymappings used in this plugin.
---@field next string Go to next cell.
---@field prev string Go to prev cell.
---@field add_row_up string Add a row above the current row.
---@field add_row_down string Add a row below the current row.
---@field add_column_left string Add a row to the left of current column.
---@field add_column_right string Add a row to the right of current column.

---@type TableNvimConfig
local uconf = {
  padd_column_separators = true,
  mappings = {
    next = '<TAB>',
    prev = '<S-TAB>',
    add_row_up = '<A-k>',
    add_row_down = '<A-j>',
    add_column_left = '<A-h>',
    add_column_right = '<A-l>',
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
