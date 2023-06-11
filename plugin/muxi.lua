if vim.g.muxi_version then
  return
end

vim.g.muxi_version = "v0.0.1"

vim.api.nvim_create_user_command("Muxi", function(args)
  require("muxi.command").load_command(args.fargs[1], args.fargs[2])
end, {
  nargs = "+",
  complete = function(arg)
    local list = require("muxi.command").command_list()

    return vim.tbl_filter(function(s)
      return string.match(s, "^" .. arg)
    end, list)
  end,
})
