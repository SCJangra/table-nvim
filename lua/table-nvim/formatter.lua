local ts = vim.treesitter

local utils = require('table-nvim.utils')
local conf = require('table-nvim.config')

-- The second row should always be the delimiter row
local delimiter_row = 2

---@class (exact) Formatter Provides functionality to format markdown tables.
---@field start number Index of the first row in the table.
---@field end_ number Index of the last row in the table.
---@field indent number Indentation of the table.
---@field rows string[][] Rows in the table, each row is an array of strings.
---@field widths number[] Widths of each column of the table.
local Formatter = {}

---@param root TSNode The root node of a table.
---@return Formatter
function Formatter:new(root)
  assert(utils.is_tbl_root(root), 'not a table root node')

  local config = conf.get_config()

  local start = root:start();
  local end_ = root:end_();
  local indent
  local widths = {}
  local rows = {}

  local r = 0
  for row in root:iter_children() do
    r = r + 1
    rows[r] = {}

    local c = 0
    for col in row:iter_children() do
      c = c + 1

      local text = ts.get_node_text(col, 0):match('^%s*(.-)%s*$')
      local width = #text

      if config.padd_column_separators and text == '|' then
        text = ' | '
        width = 3
      end

      if r == 1 then
        if c == 1 then _, indent = col:start() end
        widths[c] = width
      elseif r == delimiter_row then
        -- Do nothing
      else
        widths[c] = math.max(width, widths[c])
      end

      rows[r][c] = text
    end
  end


  ---@type Formatter
  local f = {
    start = start,
    end_ = end_,
    indent = indent,
    widths = widths,
    rows = rows
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
      local max_width = self.widths[c]

      local padding = r == delimiter_row and '-' or ' '

      if width < max_width then
        table.insert(line, col)
        if r == delimiter_row or c < #self.widths then
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

return Formatter
