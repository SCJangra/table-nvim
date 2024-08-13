local ts = vim.treesitter
local api = vim.api

local utils = require('table-nvim.utils')
local conf = require('table-nvim.config')

-- The second row should always be the delimiter row
local delimiter_row = 2

---@class (exact) ColumnInfo Information about a column in the table, including the delimiter (`|`) columns.
---@field is_delimiter boolean Is this a delimiter column.
---@field width number Text width of the column.

---@class (exact) Formatter Provides functionality to format markdown tables.
---@field start number Index of the first row in the table.
---@field end_ number Index of the last row in the table.
---@field indent number Indentation of the table.
---@field rows string[][] Rows in the table, each row is an array of strings.
---@field cols ColumnInfo[] Information about all columns in the table.
---@field cursor_col number The current column position of the cursor.
local Formatter = {}

---@param root TSNode The root node of a table.
---@return Formatter
function Formatter:new(root)
  assert(utils.is_tbl_root(root), 'not a table root node')

  local config = conf.get_config()

  local cursor_pos = api.nvim_win_get_cursor(0)
  local cursor_row, cursor_col = cursor_pos[1] - 1, cursor_pos[2]

  local start = root:start();
  local end_ = root:end_();
  local indent
  local cols = {}
  local rows = {}
  local cursor_col_index = 1

  local r = 0
  for row in root:iter_children() do
    r = r + 1
    local c_count = row:child_count()
    rows[r] = {}

    local c = 0
    for col in row:iter_children() do
      c = c + 1
      cols[c] = cols[c] or {}

      local text = ts.get_node_text(col, 0):match('^%s*(.-)%s*$')
      local width = #text
      local type = col:type()

      if ts.is_in_node_range(col, cursor_row, cursor_col) then cursor_col_index = c end

      cols[c].is_delimiter = type == '|'

      if config.padd_column_separators and type == '|' then
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
        cols[c].width = width
      elseif r == delimiter_row then
        -- Do nothing
      else
        cols[c].width = math.max(width, cols[c].width or 0)
      end

      rows[r][c] = text
    end
  end


  ---@type Formatter
  local f = {
    start = start,
    end_ = end_,
    indent = indent,
    cols = cols,
    rows = rows,
    cursor_col = cursor_col_index,
  }

  ---@diagnostic disable-next-line: inject-field
  self.__index = self
  return setmetatable(f, self)
end

---Renders the table into an array of lines
---@return string[]
function Formatter:render()
  local lines = {}

  for r, row in ipairs(self.rows) do
    local line = {}

    for c, col in ipairs(row) do
      if c == 1 then
        table.insert(line, string.rep(' ', self.indent))
      end

      local width = #col
      local max_width = self.cols[c].width

      local padding = r == delimiter_row and '-' or ' '

      if width < max_width then
        table.insert(line, col)
        if r == delimiter_row or c < #self.cols then
          table.insert(line, string.rep(padding, max_width - width))
        end
      elseif width > max_width then
        table.insert(line, string.sub(col, 1, max_width))
      else
        table.insert(line, col)
      end

      lines[r] = table.concat(line)
    end
  end

  return lines
end

function Formatter:get_delimiter()
  return conf.get_config().padd_column_separators and ' | ' or '|'
end

---Extend a row (to a given length) by inserting new columns at the end.
---@param row string[] The row to extend.
---@param len number The length to extend to.
function Formatter:extend_row_to(row, len)
  for index = #row + 1, len do
    local val = self.cols[index - 1].is_delimiter and ' ' or self:get_delimiter()
    row[index] = val
  end
end

---Generate new column data, to be inserted at `index`.
---@param row number The row in which this column will be inserted.
---@param column number The column at which this column will be inserted.
---@return string
---@return boolean
---@return string
---@return boolean
function Formatter:gen_column_for(row, column)
  local left = self.cols[column - 1]
  local current = self.cols[column]

  local left_is_delimiter = left and left.is_delimiter or nil
  local current_is_delimiter = current and current.is_delimiter or nil

  local text = function()
    if row == 1 then
      return 'x'
    elseif row == delimiter_row then
      return '-'
    else
      return ' '
    end
  end

  if left == nil and current_is_delimiter then
    return text(), false, self:get_delimiter(), true
  elseif left == nil and not current_is_delimiter then
    return self:get_delimiter(), true, text(), false
  elseif left and left_is_delimiter then
    return self:get_delimiter(), true, text(), false
  elseif left and not left_is_delimiter then
    return text(), false, self:get_delimiter(), true
  else
    -- This branch should be unreachable.
    ---@diagnostic disable-next-line: missing-return
  end
end

---Insert a column to the table at the given index.
---@param index number The index at which to add the column.
function Formatter:insert_column_at(index)
  for i, row in ipairs(self.rows) do
    self:extend_row_to(row, index - 1)

    local first, _, second, _ = self:gen_column_for(i, index)

    table.insert(row, index, first)
    table.insert(row, index, second)
  end

  local first, first_delimiter, second, second_delimiter = self:gen_column_for(1, index)

  table.insert(self.cols, index, { is_delimiter = first_delimiter, width = #first })
  table.insert(self.cols, index, { is_delimiter = second_delimiter, width = #second })
end

---Insert a column to the left of current column.
function Formatter:insert_column_left()
  self:insert_column_at(self.cursor_col)
end

---Insert a column to the left of current column.
function Formatter:insert_column_right()
  self:insert_column_at(self.cursor_col + 1)
end

return Formatter
