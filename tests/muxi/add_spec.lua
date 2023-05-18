local muxi = require("muxi")

describe("some basics", function()
  local file = "lua/muxi/init.lua"

  before_each(function()
    muxi.setup({ path = "muxi.json" })
    muxi.nuke()
    muxi:init()

    vim.cmd.edit(file)
    vim.cmd("norm! gg0")
  end)

  it("adds a key to the marks", function()
    muxi.add("j")

    assert.equals(muxi.marks, {
      j = {
        file = file,
        pos = { 1, 0 },
      },
    })
  end)

  -- it("adds a key to storage", function()
  --   muxi.add("j")
  --   assert.are.same(muxi.marks, { j = { file = "", pos = { 0, 0 } } })
  -- end)
end)
