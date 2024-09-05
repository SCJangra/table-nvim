local utils = require('table-nvim.utils')
local MdTable = require('table-nvim.md_table')
local conf = require('table-nvim.config')
local maps = require('table-nvim.keymaps')

local api = vim.api
local ts = vim.treesitter

local group_id = api.nvim_create_augroup('table-nvim', { clear = true })

api.nvim_create_autocmd({ 'InsertLeave' }, {
  group = group_id,
  pattern = { '*.md', '*.mdx' },
  callback = function()
    local root = utils.get_tbl_root(ts.get_node());
    if not root then return end

    local m = MdTable:new(root)
    local lines = m:generate_rows()

    api.nvim_buf_set_lines(0, m.start, m.end_, true, lines)
  end
})

api.nvim_create_autocmd({ 'BufEnter' }, {
  group = group_id,
  pattern = { '*.md', '*.mdx' },
  callback = function(opts) maps.set_keymaps(opts.buf) end
})

---Setup the plugin.
---@param config TableNvimConfig
local setup = function(config)
  conf.set_config(config)
end

return {
  setup = setup
}
