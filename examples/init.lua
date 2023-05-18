----Reset muxi
vim.cmd("silent !rm -f muxi.json")
for name, _ in pairs(package.loaded) do
  if name:match("^muxi") then
    package.loaded[name] = nil
  end
end

----Setup
local muxi = require("muxi")

muxi.setup({
  path = "muxi.json",
  save_cursor = false,
})

----Playground
muxi.add("l")
require("muxi.ui").show()
-- require("muxi.fzf").marks()
