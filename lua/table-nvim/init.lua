local utils = require('table-nvim.utils')

local api = vim.api
local ts = vim.treesitter

local group_id = api.nvim_create_augroup('table-nvim', { clear = true })
api.nvim_create_autocmd({ 'InsertLeave' }, {
  group = group_id,
  pattern = '*.md',
  callback = function()
    local root = utils.get_tbl_root(ts.get_node());
    if root == nil then return end
  end
})
