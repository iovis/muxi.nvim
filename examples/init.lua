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
  go_to_cursor = false,
})

----Playground
muxi.add("l")
muxi.add("k")

-- require("muxi.ui").show()
require("muxi.fzf").marks()

-- vim.cmd("messages clear")
--
-- vim.print(muxi)
--
-- vim.cmd("R! messages")
-- vim.cmd("setf lua")
-- vim.cmd("norm G")
