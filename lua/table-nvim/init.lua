local ts_utils = require('nvim-treesitter.ts_utils')

local api = vim.api

local name = 'pipe_table'
local len = #name

local group_id = api.nvim_create_augroup('table-nvim', { clear = true })
api.nvim_create_autocmd({ 'InsertEnter', 'InsertLeave' }, {
  group = group_id,
  pattern = '*.md',
  callback = function()
  end
})
