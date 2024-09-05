local C = require('table-nvim.constants')
local utils = require('table-nvim.utils')
local conf = require('table-nvim.config')

local api, ts = vim.api, vim.treesitter

---@class (exact) MdTableCell
---@field type CellType The type of this cell.
---@field text string Text of this cell.

---@class (exact) MdTableColInfo Information about a column in the table, including the delimiter (`|`) columns.
---@field is_delimiter boolean Is this a delimiter column.
---@field max_width number Text width of the column.
---@field alighment ColAlign How to align this column.

---@class (exact) MdTable Information about a markdown table.
---@field rows MdTableCell[][] Rows in this table.
---@field start number Index of the first row in the table.
---@field end_ number Index of the last row in the table.
---@field indent number Indentation of the table.
---@field cursor_col number The current column position of the cursor.
---@field cursor_row number The currow row position of the cursor.
---@field cols MdTableColInfo[] Information about all columns in the table.
---@field root TSNode The root node of the table.
---@field pipes boolean Whether the table is surrounded by pipes.
local MdTable = {}

---@param root TSNode The root node of a table.
---@return MdTable
function MdTable:new(root)
  assert(utils.is_tbl_root(root), 'not a table root node')

  local cursor_pos = api.nvim_win_get_cursor(0)
  local cursor_row, cursor_col = cursor_pos[1] - 1, cursor_pos[2]

  local start = root:start();
  local end_ = root:end_();
  local indent
  local cols = {}
  local rows = {}
  local cursor_col_index = nil
  local cursor_row_index = nil
  local pipes = false

  for r, row in utils.iter_named_children(root) do
    rows[r] = {}

    if r == 1 then
      local col = row:child(0)

      if col then
        _, indent = col:start()
        if col:type() == '|' then pipes = true end
      end
    end

    for c, col in utils.iter_named_children(row) do
      cols[c] = cols[c] or {}

      local text = ts.get_node_text(col, 0):match('^%s*(.-)%s*$')
      local width = #text
      local type = self:cell_type(text)

      -- Set the current column position of the cursor in the table.
      local end_row, end_col = col:end_()
      if not cursor_col_index and cursor_row == end_row and cursor_col < end_col then
        cursor_row_index, cursor_col_index = r, c
      end

      if r == 1 then
        cols[c].max_width = width
      elseif r == C.DELIMITER_ROW then
        if type == C.CELL_LEFT then
          cols[c].alighment = C.ALIGN_LEFT
        elseif type == C.CELL_RIGHT then
          cols[c].alighment = C.ALIGN_RIGHT
        elseif type == C.CELL_CENTER then
          cols[c].alighment = C.ALIGN_CENTER
        elseif type == C.CELL_DELIMITER then
          cols[c].alighment = C.ALIGN_NONE
        end
      else
        cols[c].max_width = math.max(width, cols[c].max_width or 0)
      end

      rows[r][c] = { type = type, text = text }
    end
  end

  ---@type MdTable
  local m = {
    start = start,
    end_ = end_,
    indent = indent,
    cols = cols,
    rows = rows,
    cursor_col = cursor_col_index or #cols,
    cursor_row = cursor_row_index or #rows,
    root = root,
    pipes = pipes,
  }

  ---@diagnostic disable-next-line: inject-field
  self.__index = self
  return setmetatable(m, self)
end

---Generate an array of formatted rows.
---@return string[]
function MdTable:generate_rows()
  local lines = {}

  for index = 1, #self.rows do lines[index] = self:generate_row(index) end

  return lines
end

---Generate a single formatted row.
---@param index number The index of the row to generate.
---@return string
function MdTable:generate_row(index)
  local padd = conf.get_config().padd_column_separators
  local line = {}
  local row = self.rows[index]

  table.insert(line, string.rep(' ', self.indent))

  if self.pipes then
    local del = padd and '| ' or '|'
    table.insert(line, del)
  end

  local cell = row[1]
  table.insert(line, self:cell_text(cell.type, cell.text, 1))

  local len = #row

  for c = 2, len do
    cell = row[c]
    local del = padd and ' | ' or '|'

    table.insert(line, del)
    table.insert(line, self:cell_text(cell.type, cell.text, c))
  end

  if self.pipes then
    local del = padd and ' |' or '|'
    table.insert(line, del)
  end

  return table.concat(line)
end

---Get the type of cell for a given string.
---@param text string
---@return CellType
function MdTable:cell_type(text)
  if text:match('^:%-+$') then return C.CELL_LEFT end
  if text:match('^%-+:$') then return C.CELL_RIGHT end
  if text:match('^:%-+:$') then return C.CELL_CENTER end
  if text:match('^%-+$') then return C.CELL_DELIMITER end

  return C.CELL_TEXT
end

---Format the cell text and return the formatted text.
---@param type CellType Type of this cell.
---@param text string Text of the cell.
---@param cell number Cell index in the row.
---@return string
function MdTable:cell_text(type, text, cell)
  if type == C.CELL_LEFT then
    local hyphens = string.rep('-', self.cols[cell].max_width - 1)
    return ':' .. hyphens
  end

  if type == C.CELL_RIGHT then
    local hyphens = string.rep('-', self.cols[cell].max_width - 1)
    return hyphens .. ':'
  end

  if type == C.CELL_CENTER then
    local hyphens = string.rep('-', self.cols[cell].max_width - 2)
    return ':' .. hyphens .. ':'
  end

  if type == C.CELL_DELIMITER then
    return string.rep('-', self.cols[cell].max_width)
  end

  local col = self.cols[cell]

  if col.alighment == C.ALIGN_LEFT or col.alighment == C.ALIGN_NONE then
    local padding = col.max_width - #text
    return text .. string.rep(' ', padding)
  end

  if col.alighment == C.ALIGN_RIGHT then
    local padding = col.max_width - #text
    return string.rep(' ', padding) .. text
  end

  local max_width = self.cols[cell].max_width
  local padding = max_width - #text
  local left_padding = math.floor(padding / 2)
  local right_padding = padding - left_padding

  return table.concat({ string.rep(' ', left_padding), text, string.rep(' ', right_padding) })
end

---Extend a row (to a given length) by inserting new cells at the end.
---@param row MdTableCell[] The row to extend.
---@param len number The length to extend to.
function MdTable:extend_row_to(row, len)
  for index = #row + 1, len do
    row[index] = { type = C.CELL_TEXT, text = ' ' }
  end
end

---Generate a new cell for the given row and column index.
---@param row_index number
---@param col_index number
---@return MdTableCell
function MdTable:gen_cell_for(row_index, col_index)
  local cell_delimiter = { text = '-', type = C.CELL_DELIMITER }
  local cell_x = { text = 'x', type = C.CELL_TEXT }
  local cell_space = { text = ' ', type = C.CELL_TEXT }

  if row_index == C.DELIMITER_ROW then return cell_delimiter end
  if row_index == 1 or col_index == 1 or col_index == #self.cols + 1 then return cell_x end
  return cell_space
end

---Insert a column to the table at the given index.
---@param index number The index at which to add the column.
function MdTable:insert_column_at(index)
  for i, row in ipairs(self.rows) do
    self:extend_row_to(row, index - 1)

    local cell = self:gen_cell_for(i, index)

    table.insert(row, index, cell)
  end

  local cell = self:gen_cell_for(1, index)

  local col_info = { max_width = #cell.text, alighment = C.ALIGN_NONE }

  table.insert(self.cols, index, col_info)
end

---Insert a column to the left of current column.
function MdTable:insert_column_left()
  self:insert_column_at(self.cursor_col)
end

---Insert a column to the left of current column.
function MdTable:insert_column_right()
  self:insert_column_at(self.cursor_col + 1)
end

---Insert a row at the given index.
---@param index number The index at which to insert the column.
function MdTable:insert_row_at(index)
  if index <= C.DELIMITER_ROW then index = C.DELIMITER_ROW + 1 end

  local row = {}

  local col_count = #self.cols
  local cell_space = { type = C.CELL_TEXT, text = ' ' }
  local cell_x = { type = C.CELL_TEXT, text = 'x' }

  row[1] = cell_x

  for c = 2, col_count - 1 do
    row[c] = cell_space
  end

  row[col_count] = cell_x

  table.insert(self.rows, index, row)

  return index
end

---Insert a row above the current row.
function MdTable:insert_row_up()
  return self:insert_row_at(self.cursor_row)
end

---Insert a row below the current row.
function MdTable:insert_row_down()
  return self:insert_row_at(self.cursor_row + 1)
end

return MdTable
