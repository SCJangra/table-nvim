local map = vim.keymap.set

local conf = require('table-nvim.config')
local nav = require('table-nvim.nav')
local edit = require('table-nvim.edit')

---Setup keymaps
---@param buf number Buffer number.
local set_keymaps = function(buf)
  local maps = conf.get_config().mappings

  local opts = { noremap = true, buffer = buf }

  map({ 'n', 'i' }, maps.next, nav.next, opts)
  map({ 'n', 'i' }, maps.prev, nav.prev, opts)
  map({ 'n', 'i' }, maps.add_row_down, edit.add_row_down, opts)
  map({ 'n', 'i' }, maps.add_row_up, edit.add_row_up, opts)
end

return {
  set_keymaps = set_keymaps
}
