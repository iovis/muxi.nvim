# muxi.nvim

Project-scoped marks for Neovim.

Save a file and cursor position to a short key, then jump back with a binding or
picker. Marks are persisted per working directory.

## Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "iovis/muxi.nvim",
  config = function()
    local muxi = require("muxi")
    muxi.setup({})
  end,
}
```

## Bindings

Most day-to-day usage is through `muxi.ui.run()`. It waits for one character:

- uppercase saves the current file and cursor position
- lowercase jumps to that mark
- in visual mode, lowercase jumps only within the current file

```lua
local muxi = require("muxi")

vim.keymap.set("n", "<leader>g", muxi.ui.run, {
  desc = "[muxi] Mark/go to file",
})

vim.keymap.set({ "n", "x" }, "m", function()
  muxi.ui.run({ go_to_cursor = true })
end, {
  desc = "[muxi] Mark/go to file (cursor: true)",
})

vim.keymap.set("n", "dm", muxi.ui.quick_delete, {
  desc = "[muxi] Delete mark",
})
```

With those mappings, `mA` saves the current location as `a`, and `ma` jumps back
to it. `ui.run()` accepts the same jump options as `muxi.go_to()`, so
`go_to_cursor` can be overridden per mapping.

If you map over Neovim's built-in `m` mark command, you may want to move the
original command:

```lua
vim.keymap.set("n", "'m", "m", { desc = "Original mark" })
vim.keymap.set("n", "''", "'", { desc = "Original go to mark" })
```

## Pickers

### Snacks

When `Snacks.picker` is available, muxi registers a picker source named
`muxi_marks`.

```lua
vim.keymap.set("n", "g/", Snacks.picker.muxi_marks, {
  desc = "snacks.picker.muxi_marks",
})
```

The Snacks picker supports adding, deleting, and renaming marks with `a`, `d`,
`r`, and `<C-x>`.

### fzf-lua

```lua
vim.keymap.set("n", "<leader>m", function()
  require("muxi.fzf").marks()
end)
```

The fzf-lua mark picker supports:

- `<C-x>`: delete selected marks
- `<C-r>`: rename the selected mark
- `<C-g>`: toggle whether jumps restore the saved cursor position

## Commands

```vim
:Muxi add a
:Muxi go a
:Muxi delete a
:Muxi clear
:Muxi qf
:Muxi fzf
```

- `:Muxi qf` opens all marks for the current project in the quickfix list.
- `:Muxi fzf` opens the fzf-lua mark picker when `fzf-lua` is installed.

## Configuration

```lua
require("muxi").setup({
  path = vim.fn.stdpath("data") .. "/muxi.json",
  go_to_cursor = true,
  signs = {
    sign_column = true,
    virtual_text = false,
  },
})
```

- `path`: JSON file used to store marks for all projects.
- `go_to_cursor`: when `true`, jumping to a mark also restores the saved cursor
  position.
- `signs.sign_column`: show the mark key in the sign column.
- `signs.virtual_text`: show the mark key as virtual text.

Set `signs = false` to disable mark rendering.

## API

```lua
local muxi = require("muxi")

muxi.add(key)
muxi.go_to(key, opts)
muxi.delete(key)
muxi.clear_all()
muxi.nuke()
muxi.marks_for_current_file()
```

- `muxi.clear_all()` clears marks for the current project.
- `muxi.nuke()` deletes the storage file, clearing marks for every project.
- `muxi.marks_for_current_file()` returns marks attached to the current file,
  which is useful for statuslines or tablines.

Example:

```lua
local keys = vim.iter(require("muxi").marks_for_current_file())
  :map(function(mark)
    return mark.key
  end)
  :join(" ")
```

Additional UI helpers:

```lua
local ui = require("muxi.ui")

ui.run()
ui.quick_delete()
ui.qf()
ui.edit()
ui.go_to_prompt()
ui.delete_prompt()
```

## Requirements

- Neovim 0.10 or newer
- Optional: [snacks.nvim](https://github.com/folke/snacks.nvim) for the Snacks
  picker source
- Optional: [fzf-lua](https://github.com/ibhagwan/fzf-lua) for the fzf picker

## Acknowledgments

Muxi borrows ideas and implementation patterns from
[fzf-lua](https://github.com/ibhagwan/fzf-lua),
[lspsaga.nvim](https://github.com/nvimdev/lspsaga.nvim),
[mini.jump](https://github.com/echasnovski/mini.jump), and
[harpoon](https://github.com/ThePrimeagen/harpoon).

## License

MIT
