# A markdown table editor
A simple (for now?) markdown table editor that formats the table as you type.

# Demo
https://github.com/user-attachments/assets/b026dc0b-4f10-48cc-81cb-3edf0f3e7772

# Dependencies
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- that's it!

# Install

Using [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
  'SCJangra/table-nvim',
  ft = 'markdown',
  opts = {},
}
```

# Default config
```lua
{
  padd_column_separators = true,   -- Insert a space around column separators.
  mappings = {
    next = '<TAB>',                -- Go to next cell.
    prev = '<S-TAB>',              -- Go to previous cell.
    insert_row_up = '<A-k>',       -- Insert a row above the current row.
    insert_row_down = '<A-j>',     -- Insert a row below the current row.
    insert_column_left = '<A-h>',  -- Insert a column to the left of current column.
    insert_column_right = '<A-l>', -- Insert a column to the right of current column.
    insert_table = '<A-t>',        -- Insert a new table.
    insert_table_alt = '<A-S-t>'   -- Insert a new table that is not surrounded by pipes.
  }
}
```
