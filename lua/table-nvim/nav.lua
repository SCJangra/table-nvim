local ts = vim.treesitter
local api = vim.api

local utils = require('table-nvim.utils')
local conf = require('table-nvim.config')

---Returns next or previous named sibling.
---@param node TSNode The node for which to get the sibling.
---@param next boolean Whether to return next or previous sibling.
---@return TSNode?
local get_named_sibling = function(node, next)
  if next then
    return node:next_named_sibling()
  else
    return node:prev_named_sibling()
  end
end

---Get next or previous node to the current node.
---@param node TSNode Current node.
---@param row number Row index of the cursor.
---@param col number Column index of the cursor.
---@param next boolean Whether to get the next or previous node.
---@return TSNode
local get_node = function(node, row, col, next)
  local root = utils.get_tbl_root(node)
  if not root then return node end

  if utils.is_tbl_align(node) then node = node:parent() or node end

  local cell = get_named_sibling(node, next)

  if not cell then
    local edge_column = utils.is_tbl_cell(node)
    local edge_row = not ts.is_in_node_range(root, next and row + 1 or row - 1, col)

    if edge_column and edge_row then
      local row_count = root:named_child_count()
      if row_count == 0 then return node end

      local next_row = next and root:named_child(0) or root:named_child(row_count - 1)
      if not next_row then return node end

      local col_count = next_row:named_child_count()
      if col_count == 0 then return node end

      local next_col = next and next_row:named_child(0) or next_row:named_child(col_count - 1)
      return next_col or node
    elseif edge_column then
      local parent_row = node:parent()
      if not parent_row then return node end

      local next_row = next and parent_row:next_named_sibling() or parent_row:prev_named_sibling()
      if not next_row then return node end

      local col_count = next_row:named_child_count()
      if col_count == 0 then return node end

      local next_col = next and next_row:named_child(0) or next_row:named_child(col_count - 1)
      return next_col or node
    elseif edge_row then
      for c in node:iter_children() do
        if ts.is_in_node_range(c, row, col) then
          return next and c:next_named_sibling() or c:prev_named_sibling() or node
        end
      end
    end

    return node
  end

  local r = cell:start()

  if row == r then return cell end

  for c in node:iter_children() do
    if ts.is_in_node_range(c, row, col) then
      local next_cell = get_named_sibling(c, next)
      if next_cell then return next_cell end

      local col_count = cell:named_child_count()
      if col_count == 0 then return node end

      next_cell = next and cell:named_child(0) or cell:named_child(col_count - 1)
      return next_cell or node
    end
  end

  return node
end

---Move to next or previous node.
---@param next boolean Whether to move to next or previous node.
local move = function(next)
  local pos = api.nvim_win_get_cursor(0)
  pos[1] = pos[1] - 1 -- Change to 0 based indexing.

  local node = ts.get_node { pos = pos }
  if not node or not utils.is_tbl_node(node) then return end

  local cell = get_node(node, pos[1], pos[2], next)
  if not cell then return end

  local row, col = cell:start()

  api.nvim_win_set_cursor(0, { row + 1, col })
end

local next = function()
  local node = ts.get_node()

  if not node or not utils.is_tbl_node(node) then
    return conf.get_config().mappings.next
  else
    return '<CMD>lua require("table-nvim.nav").move(true)<CR>'
  end
end

local prev = function()
  local node = ts.get_node()

  if not node or not utils.is_tbl_node(node) then
    return conf.get_config().mappings.prev
  else
    return '<CMD>lua require("table-nvim.nav").move(false)<CR>'
  end
end

return {
  next = next,
  prev = prev,
  move = move,
}
