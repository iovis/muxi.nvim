local muxi = require("muxi")
local assert = require("luassert")

describe("muxi.add", function()
  local file_lorem = "spec/fixtures/lorem.txt"
  local file_morel = "spec/fixtures/morel.txt"
  local test_path = "muxi_test.json"

  before_each(function()
    muxi.setup({ path = test_path })
    muxi.nuke()
    muxi:init()
  end)

  after_each(muxi.nuke)

  it("adds a key to the file and cursor position", function()
    vim.cmd.edit(file_lorem)
    vim.cmd("norm! gg0")
    muxi.add("j")

    assert.are.same(muxi.marks, {
      j = {
        file = file_lorem,
        pos = { 1, 0 },
      },
    })

    vim.cmd("norm! 2j5l")
    muxi.add("k")

    assert.are.same(muxi.marks, {
      j = {
        file = file_lorem,
        pos = { 1, 0 },
      },
      k = {
        file = file_lorem,
        pos = { 3, 5 },
      },
    })

    vim.cmd.edit(file_morel)
    vim.cmd("norm! G$")
    muxi.add("j")

    assert.are.same(muxi.marks, {
      j = {
        file = file_morel,
        pos = { 25, 38 },
      },
      k = {
        file = file_lorem,
        pos = { 3, 5 },
      },
    })
  end)
end)
