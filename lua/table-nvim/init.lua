local utils = require('table-nvim.utils')
local Metadata = require('table-nvim.metadata')
local conf = require('table-nvim.config')

local api = vim.api
local ts = vim.treesitter

local group_id = api.nvim_create_augroup('table-nvim', { clear = true })
api.nvim_create_autocmd({ 'InsertLeave' }, {
  group = group_id,
  pattern = '*.md',
  callback = function()
    local root = utils.get_tbl_root(ts.get_node());
    if not root then return end

    local m = Metadata:new(root)
    local lines = m:render()

    api.nvim_buf_set_lines(0, m.start, m.end_, true, lines)
  end
})

---Setup the plugin.
---@param config TableNvimConfig
local setup = function(config)
  conf.set_config(config)
end

return {
  setup = setup
}
