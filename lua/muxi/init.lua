local muxi = {}

-- Re-exports
muxi.test = require("muxi.test").test

---@class MuxiConfig
muxi.config = {
	path = vim.fn.stdpath("data") .. "/muxi.json",
}

---@param opts MuxiConfig
muxi.setup = function(opts)
	opts = opts or {}
	muxi.config = vim.tbl_deep_extend("force", muxi.config, opts)
end

return muxi
