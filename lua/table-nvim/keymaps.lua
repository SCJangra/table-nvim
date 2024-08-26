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
  map({ 'n', 'i' }, maps.add_row_down, edit.add_row_down, opts)
  map({ 'n', 'i' }, maps.add_row_up, edit.add_row_up, opts)
  map({ 'n', 'i' }, maps.add_column_left, edit.add_column_left, opts)
  map({ 'n', 'i' }, maps.add_column_right, edit.add_column_right, opts)
  map({ 'n', 'i' }, maps.insert_table, edit.insert_table, opts)
  map({ 'n', 'i' }, maps.insert_table_alt, edit.insert_table_alt, opts)
end

return {
  set_keymaps = set_keymaps
}
