--Shamelessly copied from lspsaga
local command = {}

local subcommands = {
  add = function(arg)
    require("muxi").add(arg)
  end,
  go = function(arg)
    require("muxi").go_to(arg)
  end,
  delete = function(arg)
    require("muxi").delete(arg)
  end,
  clear = function()
    require("muxi").clear_all()
  end,
  fzf = function()
    require("muxi.fzf").marks()
  end,
  qf = function()
    require("muxi.ui").qf()
  end,
}

function command.command_list()
  return vim.tbl_keys(subcommands)
end

function command.load_command(cmd, arg)
  subcommands[cmd](arg)
end

return command
