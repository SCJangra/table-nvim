local ts = vim.treesitter
local api = vim.api

local utils = require('table-nvim.utils')
local conf = require('table-nvim.config')
local Formatter = require('table-nvim.formatter')

---Add a new column to the table.
---@param left boolean If `true` the column is added to the left of current column, and to the right otherwise.
local add_column = function(left)
  local root = utils.get_tbl_root(ts.get_node());
  if not root then return end

  local f = Formatter:new(root)

  if left then f:insert_column_left() else f:insert_column_right() end

  local lines = f:render()

  api.nvim_buf_set_lines(0, f.start, f.end_, true, lines)
end

local add_column_left = function() add_column(true) end
local add_column_right = function() add_column(false) end

---Add a row to the table.
---@param up boolean If `true`, the row is added above current row, and below otherwise.
local add_row = function(up)
  local config = conf.get_config()

  local node = ts.get_node()
  if not node or not utils.is_tbl_node(node) then return end

  local row = nil
  if utils.is_tbl_cell(node) then row = node:parent() else row = node end
  if not row then return end

  local new_row = {}
  local last_pipe = -1
  for col in row:iter_children() do
    local _, start = col:start()

    if col:type() == '|' then
      local spaces = string.rep(' ', start - 1 - last_pipe)
      if spaces ~= '' then table.insert(new_row, spaces) end
      table.insert(new_row, '|')
      last_pipe = start
    end
  end

  -- Insert an 'x' at the first column of the new row
  local first = new_row[1]
  local second = new_row[2]
  if first == '|' then
    if config.padd_column_separators then
      first = '| x'
      if second then second = string.sub(second, 3) end
    else
      first = '|x'
      if second then second = string.sub(second, 2) end
    end
  else
    first = 'x' .. string.sub(first, 2)
  end
  new_row[1] = first
  new_row[2] = second

  -- Insert an 'x' at the last column of the new row.
  local col_count = row:child_count()
  local col_count_new = #new_row
  if col_count == col_count_new then
    local second_last = new_row[col_count_new - 1]
    if second_last and config.padd_column_separators then
      second_last = ' x' .. string.sub(second_last, 3)
    elseif second_last then
      second_last = 'x' .. string.sub(second_last, 2)
    end
    new_row[col_count_new - 1] = second_last
  else
    local x = config.padd_column_separators and ' x' or 'x'
    new_row[col_count_new + 1] = x
  end

  local r = row:start()
  r = up and r or r + 1

  api.nvim_buf_set_lines(0, r, r, true, { table.concat(new_row) })
end

local add_row_down = function() add_row(false) end
local add_row_up = function() add_row(true) end

local insert_table = function()
  local row = api.nvim_win_get_cursor(0)[1] - 1
  local lines = utils.gen_table()
  api.nvim_buf_set_lines(0, row, row + 1, true, lines)
end

local insert_table_alt = function()
  local row = api.nvim_win_get_cursor(0)[1] - 1
  local lines = utils.gen_table_alt()
  api.nvim_buf_set_lines(0, row, row + 1, true, lines)
end

return {
  add_row_down = add_row_down,
  add_row_up = add_row_up,
  add_column_left = add_column_left,
  add_column_right = add_column_right,
  insert_table = insert_table,
  insert_table_alt = insert_table_alt,
}
