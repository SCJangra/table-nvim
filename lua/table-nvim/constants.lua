---@class (exact) CellType Type of a table cell.

---@class (exact) ColAlign Alignment of a table column.

return {
  ---@type CellType
  ---All cells in header and normal rows
  CELL_TEXT = {},
  ---@type CellType
  ---A left aligned delimiter cell, like ':----'.
  ---@type CellType
  CELL_LEFT = {},
  ---@type CellType
  ---A right aligned delimiter cell, like '----:'.
  CELL_RIGHT = {},
  ---@type CellType
  ---A center aligned delimiter cell, like ':----:'.
  CELL_CENTER = {},
  ---@type CellType
  ---A non aligned delimiter cell, like '----'.
  CELL_DELIMITER = {},
  ---@type CellType
  ---A column separator, like '|'.
  CELL_PIPE = {},

  ---@type ColAlign
  ---Align a column to the left.
  ALIGN_LEFT = {},
  ---@type ColAlign
  ---Align a column to the right.
  ALIGN_RIGHT = {},
  ---@type ColAlign
  ---Align a column to the center.
  ALIGN_CENTER = {},
  ---@type ColAlign
  ---Do not align the column.
  ALIGN_NONE = {},

  ---Index of the delimiter row in a table.
  DELIMITER_ROW = 2
}
