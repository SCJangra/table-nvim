local tbl_node = 'pipe_table'
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

return {
  get_tbl_root = get_tbl_root,
  is_tbl_root = is_tbl_root,
  is_tbl_node = is_tbl_node,
}
