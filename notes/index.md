# TODO
- [x] Add a `config` object
    - [x] Holds `muxi_path`
- [x] Add a `setup` function
- [x] Add bookmark
    - [x] `muxi.add("j")`
    - [x] Should probably re-read the file before writing, to mitigate syncing issues:
        - Re-source the file
        - Add the key
        - Write the file
- [x] Go to bookmark
- [x] Clear bookmarks for this project
    - [x] Clear everything too?
- [x] Delete bookmark
- [ ] Popup with bookmarks?
    - [ ] not modifiable, similar to muxi's
    - [ ] `q` closes
    - [ ] `<cr>` go to file
    - [ ] `d` deletes?
    - [ ] `c|r` changes? What about conflicts?
    - [ ] Should I just map the keys to go to?
        - How to delete then? fzf-lua does `<c-x>`
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
vim.print("key is: " .. vim.fn.getcharstr())
```

# Notes

## Measuring time
```lua
local start = vim.fn.reltime()
-- your code
print(vim.fn.reltimestr(vim.fn.reltime(start)))
```
