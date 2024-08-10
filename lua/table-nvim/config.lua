---@class (exact) TableNvimConfig Configuration of this plugin.
---@field padd_column_separators boolean Insert a space around column separators.
---@field mappings TableNvimMappings Keymappings.

---@class (exact) TableNvimMappings Keymappings used in this plugin.
---@field next string Go to next cell.
---@field prev string Go to prev cell.

---@type TableNvimConfig
local uconf = {
  padd_column_separators = true,
  mappings = {
    next = '<TAB>',
    prev = '<S-TAB>'
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
