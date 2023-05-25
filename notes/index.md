## TODO

- [ ] [[##Superbinding Example]] Binding that listens for a keystroke
  - [ ] If it's uppercase: set mark
  - [ ] If it's lowercase and mark exists: go there
  - [ ] If it's lowercase and mark does not exist: notify it's not set
- [x] Integrate with fzf-lua
  - [ ] Try to make it a bit closer to `buffers`
  - [ ] File icons/colors
  - [ ] Maybe color muxi key?

### Done

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
- [x] (Maybe for development) Show lua table for current project
- [x] Rename `config.save_cursor` to `config.go_to_cursor`
  - [x] Make `muxi.go_to()` take `opts.cursor: boolean?`
    - [x] By default is `config.cursor`

### Canceled

- [_] Update marks on buffer or vim leave?
  - Wouldn't it defeat the purpose? You're able to put multiple marks on the same file
  - And if someone has `save_cursor: false` then it'll just go to the last position

## Bindings

1. Use chooses their own bindings:

- [x] Allow user to bind specific bindings?
  - [x] `muxi.add("j")`
  - [x] `muxi.go_to("j")`
  - [x] `muxi.clear_all()`

1. Super binding?

- [ ] Listen for a keystroke
  - [ ] If it's uppercase: set mark
  - [ ] If it's lowercase and mark exists: go there
  - [ ] If it's lowercase and mark does not exist: notify it's not set
  - [ ] ~If it's current file, ask to delete?~ => sounds annoying
  - [ ] ~Else ask to set current file to that key?~ => sounds surprising

### Superbinding Example

```lua
vim.keymap.set("n", "gm", function ()
  vim.print("key is: " .. vim.pesc(vim.fn.getcharstr()))
end)
```

## Notes

### Measuring time

```lua
local start = vim.fn.reltime()
-- your code
print(vim.fn.reltimestr(vim.fn.reltime(start)))

----Apparently there's also `os.clock()` for this
-- https://www.lua.org/pil/22.1.html
local x = os.clock()
local s = 0

for i=1,100000 do
  s = s + i
end

print(string.format("elapsed time: %.2f\n", os.clock() - x))
```
