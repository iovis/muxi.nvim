---@module 'snacks'

local muxi = require("muxi")

local M = {}

---@type snacks.picker.Config
M.source = {
  name = "muxi",
  focus = "input",
  format = "file",
  sort = { fields = { "key" } },
  matcher = {
    filename_bonus = false,
    sort_empty = true,
  },
  finder = function(_opts)
    ---@type muxi.Mark[]
    local marks = muxi.marks

    ---@type snacks.picker.finder.Item[]
    local items = {}

    for _, mark in pairs(marks) do
      items[#items + 1] = {
        text = table.concat({ mark.key, mark.file }, " "),
        label = ("[%s]"):format(mark.key),
        file = mark.file,
        pos = { mark.pos[1], mark.pos[2] },
        key = mark.key,
      }
    end

    return items
  end,
  actions = {
    muxi_add = function(picker)
      vim.ui.input({ prompt = "key" }, function(input)
        local key = vim.trim(input or "")

        if not key or vim.fn.empty(key) == 1 then
          return
        end

        local file = ""

        vim.api.nvim_buf_call(picker.input.filter.current_buf, function()
          file = vim.fn.expand("%:.")
        end)

        if vim.fn.empty(file) == 1 then
          vim.notify("[muxi] no file", vim.log.levels.ERROR)
          return
        end

        local pos = vim.api.nvim_win_get_cursor(picker.input.filter.current_win)

        muxi:sync(function(m)
          m.marks[key] = {
            file = file,
            key = key,
            pos = pos,
          }

          -- refresh list
          picker.list:set_selected()
          picker.list:set_target()
          picker:find()
        end)
      end)
    end,

    muxi_delete = function(picker)
      local items = picker:selected({ fallback = true })

      muxi:sync(function(m)
        for _, item in ipairs(items) do
          m.marks[item.key] = nil
        end

        -- refresh list
        picker.list:set_selected()
        picker.list:set_target()
        picker:find()
      end)
    end,

    muxi_rename = function(picker)
      local old_key = picker:selected({ fallback = true })[1].key
      local mark = muxi.marks[old_key]

      vim.ui.input({ prompt = "New key " }, function(input)
        local new_key = vim.trim(input or "")

        if vim.fn.empty(new_key) == 1 then
          return
        end

        muxi:sync(function(m)
          if m.marks[new_key] then
            -- If key is already in use, switch it with the old one
            m.marks[new_key].key = old_key
            m.marks[old_key] = m.marks[new_key]
          else
            -- Otherwise, remove the old mark
            m.marks[old_key] = nil
          end

          mark.key = new_key
          m.marks[new_key] = mark

          -- refresh list
          picker.list:set_selected()
          picker.list:set_target()
          picker:find()
        end)
      end)
    end,
  },
  win = {
    input = {
      keys = {
        ["<c-x>"] = { "muxi_delete", mode = { "n", "i" } },
        a = "muxi_add",
        d = "muxi_delete",
        r = "muxi_rename",
      },
    },
    list = {
      keys = {
        ["<c-x>"] = "muxi_delete",
        a = "muxi_add",
        d = "muxi_delete",
        r = "muxi_rename",
      },
    },
  },
}

return M
