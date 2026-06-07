local root = vim.env.MUXI_TEST_REPO or vim.fn.getcwd()

vim.opt.runtimepath:prepend(root)
vim.opt.shadafile = "NONE"
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

package.path = table.concat({
  root .. "/?.lua",
  root .. "/?/init.lua",
  root .. "/lua/?.lua",
  root .. "/lua/?/init.lua",
  root .. "/tests/?.lua",
  root .. "/tests/?/init.lua",
  package.path,
}, ";")
