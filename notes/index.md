# TODO
- [x] Add a `config` object
    - [x] Holds `muxi_path`
- [x] Add a `setup` function
- [x] Add bookmark
    - [x] `muxi.add("j")`
    - [x] Should probably re-read the file before writing, to mitigate syncing issues:
- [x] Go to bookmark
- [x] Clear bookmarks for this project
    - [x] Clear everything too?
- [x] Delete bookmark
- [x] Integrate with fzf-lua
- [x] (Maybe for development) Show lua table for current project
- [ ] Update marks on buffer or vim leave?
    - [ ] Maybe a `config` option?


# Bindings

1. Use chooses their own bindings:
- [x] Allow user to bind specific bindings?
    - [x] `muxi.add("j")`
    - [x] `muxi.go_to("j")`
    - [x] `muxi.list_sessions()`
    - [x] `muxi.clear_all()`

2. Super binding?
- [ ] Listen for a keystroke
    - [ ] If it exists and it's not current file, go there
    - [ ] If it's current file, ask to delete?
    - [ ] Else ask to set current file to that key?

```lua
vim.keymap.set("n", "gm", function ()
  vim.print("key is: " .. vim.pesc(vim.fn.getcharstr()))
end)
```

# Notes

## Measuring time
```lua
local start = vim.fn.reltime()
-- your code
print(vim.fn.reltimestr(vim.fn.reltime(start)))
```
