local tbl_node = 'pipe_table'
local tbl_cell = 'pipe_table_cell'
local tbl_delimiter_cell = 'pipe_table_delimiter_cell'
local tbl_node_len = #tbl_node

---Returns `true` if the node is the root of a markdown table and `false` otherwise.
---@param node TSNode The node to check.
local is_tbl_root = function(node)
  return node:type() == tbl_node
end

---Returns `true` if the node belongs to a markdown table and `false` otherwise.
---@param node TSNode The node to check.
local is_tbl_node = function(node)
  return string.sub(node:type(), 1, tbl_node_len) == tbl_node
end

---@param node TSNode? A node within a markdown table
---@return TSNode? tbl_root Root node of a markdown table, if the `node` does not belong to a markdown table, then `nil` is returned
local get_tbl_root = function(node)
  if node == nil then return nil end
  if string.sub(node:type(), 1, tbl_node_len) ~= tbl_node then return nil end

  while true do
    node = node:parent()
    if node == nil then return nil end
    if is_tbl_root(node) then return node end
  end
end

---Check if a positon is withing some range.
---@param row number Row position to check.
---@param col number Column position to check.
---@param row_start number Starting row of the range.
---@param col_start number Starting column of the range.
---@param row_end number Ending row of the range.
---@param col_end number Ending column of the range.
local is_in_range = function(row, col, row_start, col_start, row_end, col_end)
  if (row == row_start and row == row_end and col >= col_start and col <= col_end) or
      (row == row_start and row < row_end and col >= col_start) or
      (row > row_start and row == row_end and col <= col_end) or
      (row > row_start and row < row_end) then
    return true
  else
    return false
  end
end

---Returns `true` if the provided node is a table cell and `false` otherwise.
local is_tbl_cell = function(node)
  local type = node:type()
  return type == tbl_cell or type == tbl_delimiter_cell
end

return {
  get_tbl_root = get_tbl_root,
  is_tbl_root = is_tbl_root,
  is_tbl_node = is_tbl_node,
  is_in_range = is_in_range,
  is_tbl_cell = is_tbl_cell,
}
