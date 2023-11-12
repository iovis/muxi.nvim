local assert = require("luassert")

describe("muxi.setup", function()
  local muxi = require("muxi")
  local default_path = vim.fn.stdpath("data") .. "/muxi.json"
  local test_path = "muxi_test.json"

  before_each(function()
    package.loaded.muxi = nil
    muxi = require("muxi")
  end)

  after_each(function()
    muxi.nuke()
    package.loaded.muxi = nil
  end)

  describe("with default configuration", function()
    it("sets the default values", function()
      muxi.setup({})

      assert.are.equal(muxi.config.path, default_path)
      assert.are.equal(muxi.config.go_to_cursor, true)

      -- Don't mess with my sessions
      muxi.setup({ path = test_path })
      print(muxi.config.path)
    end)
  end)

  describe("with custom configuration", function()
    it("uses the specified values", function()
      muxi.setup({
        path = test_path,
        go_to_cursor = false,
      })

      assert.are.equal(muxi.config.path, test_path)
      assert.are.equal(muxi.config.go_to_cursor, false)
    end)
  end)

  describe("with existing marks", function()
    it("loads the marks", function()
      pending("create a file and check that the marks are loaded")
    end)
  end)
end)
