local ts = vim.treesitter
local api = vim.api

local utils = require('table-nvim.utils')
local MdTable = require('table-nvim.md_table')

---Add a new column to the table.
---@param left boolean If `true` the column is added to the left of current column, and to the right otherwise.
local insert_column = function(left)
  local root = utils.get_tbl_root(ts.get_node());
  if not root then return end

  local t = MdTable:new(root)

  if left then t:insert_column_left() else t:insert_column_right() end

  t:render()
end

local insert_column_left = function() insert_column(true) end
local insert_column_right = function() insert_column(false) end

---Insert a new column to the table.
---@param up boolean If `true` the row is insert above current row, and below otherwise.
local insert_row = function(up)
  local root = utils.get_tbl_root(ts.get_node());
  if not root then return end

  local t = MdTable:new(root)

  local index = up and t:insert_row_up() or t:insert_row_down()

  t:render_row(index)
end

local insert_row_up = function() insert_row(true) end
local insert_row_down = function() insert_row(false) end

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

local delete_current_column = function()
  local root = utils.get_tbl_root(ts.get_node());
  if not root then return end

  local t = MdTable:new(root)
  t:delete_current_column()
  t:render()
end

local move_column = function(left)
  local root = utils.get_tbl_root(ts.get_node());
  if not root then return end

  local t = MdTable:new(root)
  local first = t.cursor_col
  local second = left and first - 1 or first + 1

  if left and second < 1 then return end
  if not left and second > #t.cols then return end

  vim.print(t.cursor_row, t.cursor_col)

  t:swap_columns(first, second)
  t:render()
  t:move_cursor_to(t.cursor_row, second)
end

local move_column_left = function() move_column(true) end
local move_column_right = function() move_column(false) end

return {
  insert_row_up = insert_row_up,
  insert_row_down = insert_row_down,

  insert_column_left = insert_column_left,
  insert_column_right = insert_column_right,

  insert_table = insert_table,
  insert_table_alt = insert_table_alt,

  move_column_left = move_column_left,
  move_column_right = move_column_right,

  delete_current_column = delete_current_column,
}
