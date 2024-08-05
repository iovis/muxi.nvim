## TODO

- [ ] Documentation
  - [ ] Add README.md
    - [ ] Acknowledgments
      - [ ] Fzf-lua
      - [ ] lspsaga
      - [ ] mini.jump
  - [ ] Generate vimdocs from README.md?

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
- [x] Integrate with fzf-lua
  - [x] Try to make it a bit closer to `buffers`
  - [x] File icons/colors
  - [x] Maybe color muxi key?
  - [x] [API Questions](https://github.com/ibhagwan/fzf-lua/issues/773#issuecomment-1574001862)
    - [x] Leverage fzf's `reload` for better UX
    - [x] `fzf_cb` should not be necessary
    - [x] `git_icons` is still not working
      - `file_icons` and `color_icons` started working when using `make_entry.file`
      => You need to call `make_entry.preprocess` once before making any entries!
    - [x] `opts = fzf_lua.core.set_fzf_field_index(opts, 3, opts._is_skim and "{}" or "{..-2}")`
      - not sure what this line means
        - It's used for native previewers (bat) together with skim (rust version of fzf)
    - [x] `MuxiMarkRow` should not be necessary, there's no way around getting strings back because it's an external process
      - Could still be useful to keep track of `mark.key`
    - [x] `fzf.utils.strip_ansi_coloring` for escaping colors
      - Looks like fzf_lua is doing the heavy lifting for me
    - [x] `make_entry.file` for playing nice with the API
    - [x] `fzf_opts --headed` for making legends
    - [x] `config.set_action_helpstr(fn, helpstr)` for setting the help string of a custom action (but try to use native ones)
    - [x] `dap_breakpoints` is a good one to copy
- [x] Make `:Muxi` commands (complete)
  - [x] `:Muxi add <key>`
  - [x] `:Muxi go <key>` (complete)
  - [x] `:Muxi delete <key>` (complete)
  - [x] `:Muxi clear`
  - [x] `:Muxi fzf`
  - Maybe check neotree or lspsaga for the completion
    - Lspsaga does it in lua
- [x] [[##Superbinding Example]] Binding that listens for a keystroke
  - [x] If it's uppercase: set mark
  - [x] If it's lowercase and mark exists: go there
  - [x] If it's lowercase and mark does not exist: notify it's not set
  - Copy something like `mini.jump`

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

- [x] Listen for a keystroke
  - [x] If it's uppercase: set mark
  - [x] If it's lowercase and mark exists: go there
  - [x] If it's lowercase and mark does not exist: notify it's not set
  - [_] ~If it's current file, ask to delete?~ => sounds annoying
  - [_] ~Else ask to set current file to that key?~ => sounds surprising

### Superbinding Example

```lua
vim.keymap.set("n", "gm", function()
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

for i = 1, 100000 do
  s = s + i
end

print(string.format("elapsed time: %.2f\n", os.clock() - x))
```
