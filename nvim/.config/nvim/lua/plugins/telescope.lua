return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },

    config = function()
      local telescope = require "telescope"
      local actions = require "telescope.actions"
      local builtin = require "telescope.builtin"

      local function telescope_buffer_dir()
        return vim.fn.expand "%:p:h"
      end

      local fb_actions = require("telescope").extensions.file_browser.actions

      telescope.setup {
        defaults = {
          mappings = {
            n = {
              ["q"] = actions.close,
            },
          },
        },
        extensions = {
          file_browser = {
            theme = "dropdown",
            -- disables netrw and use telescope-file-browser in its place
            hijack_netrw = true,
            mappings = {
              -- your custom insert mode mappings
              ["i"] = {
                ["<C-w>"] = function()
                  vim.cmd "normal vbd"
                end,
              },
              ["n"] = {
                -- your custom normal mode mappings
                ["N"] = fb_actions.create,
                ["h"] = fb_actions.goto_parent_dir,
                ["l"] = actions.select_default,
                ["/"] = function()
                  vim.cmd "startinsert"
                end,
              },
            },
          },
        },
      }

      telescope.load_extension "file_browser"

      vim.keymap.set("n", "<leader>ff", function()
        builtin.find_files {
          no_ignore = false,
          hidden = true,
        }
      end)
      vim.keymap.set("n", "<leader>fg", function()
        builtin.live_grep()
      end)
      vim.keymap.set("n", "<leader>fb", function()
        builtin.buffers()
      end)
      vim.keymap.set("n", "<leader>fh", function()
        builtin.help_tags()
      end)
      vim.keymap.set("n", "<leader>fr", function()
        builtin.resume()
      end)
      vim.keymap.set("n", "<leader>fd", function()
        builtin.diagnostics()
      end)
      vim.keymap.set("n", "<leader>sf", function()
        telescope.extensions.file_browser.file_browser {
          path = "%:p:h",
          cwd = telescope_buffer_dir(),
          respect_gitignore = false,
          hidden = true,
          grouped = true,
          previewer = false,
          initial_mode = "normal",
          layout_config = { height = 40 },
        }
      end)
      vim.keymap.set("n", "<leader>fp", function()
        builtin.git_files()
      end)
    end,

    keys = {
      "<leader>ff",
      "<leader>fg",
      "<leader>fb",
      "<leader>fh",
      "<leader>fr",
      "<leader>fd",
      "<leader>sf",
      "<leader>fp",
    },
  },

  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    lazy = true,
  },
}
