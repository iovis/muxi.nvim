-- Integration with https://github.com/ibhagwan/fzf-lua
local fzf_installed, fzf_lua = pcall(require, "fzf-lua")
if not fzf_installed then
  vim.notify("fzf-lua not found!", vim.log.levels.ERROR)
  return
end

local M = {}
local muxi = require("muxi")

local fzf_actions = require("fzf-lua.actions")
local MuxiPreviewer = require("muxi.fzf.previewer")

function M.marks()
  fzf_lua.fzf_exec(function(fzf_cb)
    local marks = {}

    for key, value in pairs(muxi.marks) do
      table.insert(marks, string.format("[%s] %s", key, value.file))
    end

    table.sort(marks)

    for _, mark in ipairs(marks) do
      fzf_cb(mark)
    end

    fzf_cb()
  end, {
    prompt = "muxi> ",
    ----Not working yet
    -- git_icons = true,
    -- file_icons = true,
    -- color_icons = true,
    ---------------------
    previewer = MuxiPreviewer,
    actions = {
      default = function(selected, _)
        for _, item in ipairs(selected) do
          local key = item:match("%[(.-)%]")
          muxi.go_to(key)
        end
      end,
      ["ctrl-s"] = function(selected, _)
        for _, item in ipairs(selected) do
          local key = item:match("%[(.-)%]")
          vim.cmd.new()
          muxi.go_to(key)
        end
      end,
      ["ctrl-v"] = function(selected, _)
        for _, item in ipairs(selected) do
          local key = item:match("%[(.-)%]")
          vim.cmd.vnew()
          muxi.go_to(key)
        end
      end,
      ["ctrl-t"] = function(selected, _)
        for _, item in ipairs(selected) do
          local key = item:match("%[(.-)%]")
          vim.cmd.tabnew()
          muxi.go_to(key)
        end
      end,
      ["ctrl-x"] = {
        function(selected, _)
          for _, item in ipairs(selected) do
            local key = item:match("%[(.-)%]")
            muxi.delete(key)
          end
        end,
        fzf_actions.resume,
      },
    },
  })
end

return M
