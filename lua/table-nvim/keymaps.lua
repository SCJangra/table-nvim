local map = vim.keymap.set

local conf = require('table-nvim.config')
local nav = require('table-nvim.nav')

local opts = { noremap = true }

local set_keymaps = function()
  local maps = conf.get_config().mappings

  map({ 'n', 'i' }, maps.next, nav.next, opts)
  map({ 'n', 'i' }, maps.prev, nav.prev, opts)
end

return {
  set_keymaps = set_keymaps
}
