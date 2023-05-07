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
- [ ] ~Clear bookmarks for this project~
    - [ ] Clear everything too?
- [ ] Delete bookmark or just manage in popup?
    - [ ] Both?
- [ ] Popup with bookmarks?
    - [ ] not modifiable, similar to muxi's
    - [ ] `q` closes
    - [ ] `<cr>` go to file
    - [ ] `d` deletes?
    - [ ] `c|r` changes? What about conflicts?
    - [ ] Should I just map the keys to go to?
        - How to delete then? fzf-lua does `<c-x>`
- [ ] (Maybe for development) Show lua table for current project
    - [ ] Reset `muxi[cwd]` to the buffer contents before leaving the buffer
    - [ ] Can I prevent closing the buffer if the config is invalid?
- [ ] Update marks on buffer or vim leave?
    - [ ] Maybe a `config` option?


# Bindings

1. Use chooses their own bindings:
- [ ] Allow user to bind specific bindings?
    - [ ] `muxi.add("j")`
    - [ ] `muxi.go_to("j")`
    - [ ] `muxi.list_sessions()`
    - [ ] `muxi.clear_project()`
    - [ ] `muxi.clear_all()`

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
