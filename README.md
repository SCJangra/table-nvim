# A markdown table editor
A simple (for now?) markdown table editor that formats the table as you type.

# Demo
https://github.com/user-attachments/assets/f015f23f-d53b-4228-a6f8-5c7af259bfc8

# Dependencies
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- that's it!

# Install
```lua
use {
  'SCJangra/table-nvim',
  ft = 'markdown',
  opts = {},
}
```

# Default config
```lua
  padd_column_separators = true,  -- Insert a space around column separators
  mappings = {
    next = '<TAB>',               -- Go to next cell
    prev = '<S-TAB>',             -- Go to prev cell
    add_row_up = '<A-k>',         -- Add a row above the current row
    add_row_down = '<A-j>',       -- Add a row below the current row
    add_column_left = '<A-h>',    -- Add a column to the left of current column
    add_column_right = '<A-l>',   -- Add a column to the right of current column
    insert_table = '<A-t>',       -- Insert a new table
    insert_table_alt = '<A-S-t>', -- Insert a new table that is not surrounded by pipes
  }
}
```