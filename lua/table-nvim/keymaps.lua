local map = vim.keymap.set

local conf = require('table-nvim.config')
local nav = require('table-nvim.nav')
local edit = require('table-nvim.edit')

---Setup keymaps
---@param buf number Buffer number.
local set_keymaps = function(buf)
  local maps = conf.get_config().mappings

  local function opts(desc)
    return { noremap = true, buffer = buf, desc = desc }
  end
  local function opts_expr(desc)
    return { noremap = true, buffer = buf, expr = true, desc = desc }
  end

  map({ 'n', 'i' }, maps.next, nav.next, opts_expr('Go to next cell'))
  map({ 'n', 'i' }, maps.prev, nav.prev, opts_expr('Go to previous cell'))
  map('n', maps.insert_row_up, edit.insert_row_up, opts('Insert row up'))
  map('n', maps.insert_row_down, edit.insert_row_down, opts('Insert row down'))
  map('n', maps.move_row_up, edit.move_row_up, opts('Move row up'))
  map('n', maps.move_row_down, edit.move_row_down, opts('Move row down'))
  map('n', maps.insert_column_left, edit.insert_column_left, opts('Insert column left'))
  map('n', maps.insert_column_right, edit.insert_column_right, opts('Insert column right'))
  map('n', maps.move_column_left, edit.move_column_left, opts('Move column left'))
  map('n', maps.move_column_right, edit.move_column_right, opts('Move column right'))
  map('n', maps.insert_table, edit.insert_table, opts('Insert table'))
  map('n', maps.insert_table_alt, edit.insert_table_alt, opts('Insert table (no outline)'))
  map('n', maps.delete_column, edit.delete_current_column, opts('Delete column'))
end

return {
  set_keymaps = set_keymaps
}
