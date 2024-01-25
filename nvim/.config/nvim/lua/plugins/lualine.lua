return {
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      local status, lualine = pcall(require, "lualine")
      if not status then
        return
      end

      local function maximize_status()
        return vim.t.maximized and "   " or ""
      end

      local function getLspName()
        local msg = " "
        local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
        local clients = vim.lsp.get_active_clients()
        if next(clients) == nil then
          return msg
        end
        for _, client in ipairs(clients) do
          local filetypes = client.config.filetypes
          if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
            return msg .. " " .. client.name
          end
        end
        return msg
      end

      local lsp = {
        function()
          return getLspName()
        end,
        separator = { left = "", right = "" },
      }

      lualine.setup {
        options = {
          theme = "auto",
          component_separators = "|",
          section_separators = "",
          -- section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = {
            { "mode", separator = { left = "" }, right_padding = 2 },
          },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { maximize_status, "filename" },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress", "location" },
          lualine_z = {
            lsp,
          },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {},
        winbar = {},
        inactive_winbar = {},
        extensions = {},
      }
    end,
  },
}
