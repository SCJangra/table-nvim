local tbl_node = 'pipe_table'
local tbl_node_len = #tbl_node

---@param node TSNode? a node within a markdown table
---@return TSNode? tbl_root root node of a markdown table, if the `node` does not belong to a markdown table, then `nil` is returned
local get_tbl_root = function(node)
  if node == nil then return nil end
  if string.sub(node:type(), 1, tbl_node_len) ~= tbl_node then return nil end

  while true do
    node = node:parent()
    if node == nil then return nil end
    if node:type() == tbl_node then return node end
  end
end

return {
  get_tbl_root = get_tbl_root
}
