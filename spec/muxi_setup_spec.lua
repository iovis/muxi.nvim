local assert = require("luassert")

describe("muxi.setup", function()
  local muxi = require("muxi")
  local default_path = vim.fn.stdpath("data") .. "/muxi.json"

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
    end)
  end)

  describe("with custom configuration", function()
    it("config.path", function()
      muxi.setup({
        path = "muxi_test.json",
      })

      assert.are.equal(muxi.config.path, "muxi_test.json")
      assert.are.equal(muxi.config.go_to_cursor, true)
    end)

    it("config.go_to_cursor", function()
      muxi.setup({
        go_to_cursor = false,
      })

      assert.are.equal(muxi.config.path, default_path)
      assert.are.equal(muxi.config.go_to_cursor, false)
    end)

    it("all", function()
      muxi.setup({
        path = "muxi_test.json",
        go_to_cursor = false,
      })

      assert.are.equal(muxi.config.path, "muxi_test.json")
      assert.are.equal(muxi.config.go_to_cursor, false)
    end)
  end)

  describe("with existing marks", function()
    it("loads the marks", function()
      pending("create a file and check that the marks are loaded")
    end)
  end)
end)
