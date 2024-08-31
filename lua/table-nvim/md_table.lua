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
---@field root TSNode the root node of the table.
local MdTable = {}

---@param root TSNode The root node of a table.
---@return MdTable
function MdTable:new(root)
  assert(utils.is_tbl_root(root), 'not a table root node')

  local config = conf.get_config()

  local cursor_pos = api.nvim_win_get_cursor(0)
  local cursor_row, cursor_col = cursor_pos[1] - 1, cursor_pos[2]

  local start = root:start();
  local end_ = root:end_();
  local indent
  local cols = {}
  local rows = {}
  local cursor_col_index = nil
  local cursor_row_index = nil

  for r, row in utils.iter_children(root) do
    local c_count = row:child_count()
    rows[r] = {}

    for c, col in utils.iter_children(row) do
      cols[c] = cols[c] or {}

      local text = ts.get_node_text(col, 0):match('^%s*(.-)%s*$')
      local width = #text
      local type = self:cell_type(text)

      -- Set the current column position of the cursor in the table.
      local end_row, end_col = col:end_()
      if not cursor_col_index and cursor_row == end_row and cursor_col < end_col then
        cursor_row_index, cursor_col_index = r, c
      end

      cols[c].is_delimiter = type == C.CELL_PIPE

      if config.padd_column_separators and type == C.CELL_PIPE then
        if c == 1 then
          text = '| '
        elseif c == c_count then
          text = ' |'
        else
          text = ' | '
        end

        width = #text
      end

      if r == 1 then
        if c == 1 then _, indent = col:start() end
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
    cursor_col = cursor_col_index or 1,
    cursor_row = cursor_row_index or 1,
    root = root,
  }

  ---@diagnostic disable-next-line: inject-field
  self.__index = self
  return setmetatable(m, self)
end

---Renders the table into an array of lines
---@return string[]
function MdTable:render()
  local lines = {}

  for index = 1, #self.rows do lines[index] = self:render_row(index) end

  return lines
end

---Renders a particular row into a string.
---@param index number The index of the row to render.
---@return string
function MdTable:render_row(index)
  local line = {}

  for c, cell in ipairs(self.rows[index]) do
    if c == 1 then table.insert(line, string.rep(' ', self.indent)) end
    table.insert(line, self:cell_text(cell.type, cell.text, c))
  end

  return table.concat(line)
end

---Get the type of cell for a given string.
---@param text string
---@return CellType
function MdTable:cell_type(text)
  if text == '|' then return C.CELL_PIPE end

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
  if type == C.CELL_PIPE then return self:delimiter(cell) end

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

---Get delimiter for the given cell
---@param cell_index number
function MdTable:delimiter(cell_index)
  local padd = conf.get_config().padd_column_separators

  if cell_index == 1 then return padd and '| ' or '|' end
  if cell_index == #self.cols then return padd and ' |' or '|' end

  return padd and ' | ' or '|'
end

---Extend a row (to a given length) by inserting new cells at the end.
---@param row MdTableCell[] The row to extend.
---@param len number The length to extend to.
function MdTable:extend_row_to(row, len)
  for index = #row + 1, len do
    local text = row[index - 1].type == C.CELL_PIPE and ' ' or self:delimiter(index)
    row[index] = { type = C.CELL_TEXT, text = text }
  end
end

---Generate a new cell for the given row and column index.
---@param row_index number
---@param col_index number
---@return MdTableCell, MdTableCell
function MdTable:gen_cell_for(row_index, col_index)
  local left = self.rows[row_index][col_index - 1]
  local current = self.rows[row_index][col_index]

  local left_is_pipe = left and left.type == C.CELL_PIPE
  local current_is_pipe = current and current.type == C.CELL_PIPE

  local text = function()
    local cell_delimiter = { text = '-', type = C.CELL_DELIMITER }
    local cell_x = { text = 'x', type = C.CELL_TEXT }
    local cell_space = { text = ' ', type = C.CELL_TEXT }

    if col_index == 1 then
      if row_index == C.DELIMITER_ROW then return cell_delimiter else return cell_x end
    end

    if col_index == 2 and left_is_pipe then
      if row_index == C.DELIMITER_ROW then return cell_delimiter else return cell_x end
    end

    if col_index == #self.cols and current_is_pipe then
      if row_index == C.DELIMITER_ROW then return cell_delimiter else return cell_x end
    end

    if col_index == #self.cols + 1 then
      if row_index == C.DELIMITER_ROW then return cell_delimiter else return cell_x end
    end

    if row_index == 1 then return cell_x end
    if row_index == C.DELIMITER_ROW then return cell_delimiter end

    return cell_space
  end

  local delimiter = { text = self:delimiter(col_index), type = C.CELL_PIPE }

  if left == nil and current_is_pipe then
    return text(), delimiter
  elseif left == nil and not current_is_pipe then
    return delimiter, text()
  elseif left and left_is_pipe then
    return delimiter, text()
  elseif left and not left_is_pipe then
    return text(), delimiter
  else
    -- This branch should be unreachable.
    ---@diagnostic disable-next-line: missing-return
  end
end

---Insert a column to the table at the given index.
---@param index number The index at which to add the column.
function MdTable:insert_column_at(index)
  for i, row in ipairs(self.rows) do
    self:extend_row_to(row, index - 1)

    local first, second = self:gen_cell_for(i, index)

    table.insert(row, index, first)
    table.insert(row, index, second)
  end

  local first, second = self:gen_cell_for(1, index)

  local a = { is_delimiter = first.type == C.CELL_PIPE, max_width = #first.text, alighment = C.ALIGN_NONE }
  local b = { is_delimiter = second.type == C.CELL_PIPE, max_width = #second.text, alighment = C.ALIGN_NONE }

  table.insert(self.cols, index, a)
  table.insert(self.cols, index, b)
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

  for c, col in ipairs(self.cols) do
    if (c == 1 or c == 2 or c == col_count or c == col_count - 1) and not col.is_delimiter then
      row[c] = { type = C.CELL_TEXT, text = 'x' }
    elseif col.is_delimiter then
      row[c] = { type = C.CELL_PIPE, text = '|' }
    else
      row[c] = { type = C.CELL_TEXT, text = ' ' }
    end
  end

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
