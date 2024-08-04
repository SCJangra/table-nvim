local ts = vim.treesitter

local get_config = require('table-nvim.config').get_config

---@class (exact) Metadata metadata related to a markdown table.
---@field start number Index of the first row in the table.
---@field end_ number Index of the last row in the table.
---@field indent number Indentation of the table.
---@field rows string[][] Rows in the table, each row is an array of strings.
---@field widths number[] Widths of each column of the table.
local Metadata = {}

---Parse metadata from a table root node.
---@param root TSNode The root node of a table.
---@return Metadata
function Metadata:new(root)
  assert(root:type() == 'pipe_table', 'not a table root node')

  local config = get_config()

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

      if r == 1 then
        if c == 1 then _, indent = col:start() end
        widths[c] = width
      else
        widths[c] = math.max(width, widths[c])
      end

      if config.padd_column_separators and text == '|' then text = ' | ' end

      rows[r][c] = text
    end
  end


  ---@type Metadata
  local m = {
    start = start,
    end_ = end_,
    indent = indent,
    widths = widths,
    rows = rows
  }

  ---@diagnostic disable-next-line: inject-field
  self.__index = self
  return setmetatable(m, self)
end

---Renders the table into an array of lines
---@return string[]
function Metadata:render()
  local lines = {}

  for r, row in ipairs(self.rows) do
    local line = {}

    for c, col in ipairs(row) do
      if c == 1 then
        table.insert(line, string.rep(' ', self.indent))
      end

      table.insert(line, col)

      local width = #col
      local max_width = self.widths[c]

      if width < max_width then
        table.insert(line, string.rep(' ', max_width - width))
      end

      lines[r] = table.concat(line)
    end
  end

  return lines
end

return Metadata
