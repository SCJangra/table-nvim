local map = vim.keymap.set

local conf = require('table-nvim.config')
local nav = require('table-nvim.nav')
local edit = require('table-nvim.edit')

---Setup keymaps
---@param buf number Buffer number.
local set_keymaps = function(buf)
  local maps = conf.get_config().mappings

  local opts = { noremap = true, buffer = buf }
  local opts_expr = { noremap = true, buffer = buf, expr = true }

  map({ 'n', 'i' }, maps.next, nav.next, opts_expr)
  map({ 'n', 'i' }, maps.prev, nav.prev, opts_expr)
  map('n', maps.insert_row_up, edit.insert_row_up, opts)
  map('n', maps.insert_row_down, edit.insert_row_down, opts)
  map('n', maps.move_row_up, edit.move_row_up, opts)
  map('n', maps.move_row_down, edit.move_row_down, opts)
  map('n', maps.insert_column_left, edit.insert_column_left, opts)
  map('n', maps.insert_column_right, edit.insert_column_right, opts)
  map('n', maps.move_column_left, edit.move_column_left, opts)
  map('n', maps.move_column_right, edit.move_column_right, opts)
  map('n', maps.insert_table, edit.insert_table, opts)
  map('n', maps.insert_table_alt, edit.insert_table_alt, opts)
  map('n', maps.delete_column, edit.delete_current_column, opts)
end

return {
  set_keymaps = set_keymaps
}
