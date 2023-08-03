return {
  -- Automatic toggling between line number modes
  "jeffkreeftmeijer/vim-numbertoggle",

  { "nvim-tree/nvim-web-devicons", lazy = true },

  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  {
    "declancm/maximize.nvim", -- maximize window: <leader>z
    config = function()
      require("maximize").setup()
    end,
  },

  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    config = function()
      require("nvim-surround").setup {
        -- Configuration here, or leave empty to use defaults
      }
    end,
  },

  "ThePrimeagen/vim-be-good",

  {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup()
    end,
  },

  -- "theprimeagen/harpoon",
  {
    "mbbill/undotree",
    config = function()
      vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
    end,
  },

  {
    "j-hui/fidget.nvim",
    config = function()
      require("fidget").setup {
        text = {
          spinner = "clock", -- animation shown when tasks are ongoing
        },
        sources = {
          ["null-ls"] = {
            ignore = true,
          },
        },
      }
    end,
  },

  {
    "folke/todo-comments.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
      require("todo-comments").setup {}
    end,
  },

  {
    "johnfrankmorgan/whitespace.nvim",
    config = function()
      require("whitespace-nvim").setup {
        -- configuration options and their defaults

        -- `highlight` configures which highlight is used to display
        -- trailing whitespace
        highlight = "DiffDelete",

        -- `ignored_filetypes` configures which filetypes to ignore when
        -- displaying trailing whitespace
        ignored_filetypes = { "TelescopePrompt", "Trouble", "help" },
      }

      -- remove trailing whitespace with a keybinding
      -- vim.keymap.set('n', '<Leader>t', require('whitespace-nvim').trim)
    end,
  },

  {
    "alexghergh/nvim-tmux-navigation",
    config = function()
      local nvim_tmux_nav = require "nvim-tmux-navigation"

      nvim_tmux_nav.setup {
        disable_when_zoomed = true, -- defaults to false
      }

      vim.keymap.set("n", "<C-h>", nvim_tmux_nav.NvimTmuxNavigateLeft)
      vim.keymap.set("n", "<C-j>", nvim_tmux_nav.NvimTmuxNavigateDown)
      vim.keymap.set("n", "<C-k>", nvim_tmux_nav.NvimTmuxNavigateUp)
      vim.keymap.set("n", "<C-l>", nvim_tmux_nav.NvimTmuxNavigateRight)
      vim.keymap.set("n", "<C-\\>", nvim_tmux_nav.NvimTmuxNavigateLastActive)
      vim.keymap.set("n", "<C-Space>", nvim_tmux_nav.NvimTmuxNavigateNext)
    end,
  },

  {
    "sindrets/diffview.nvim",
    dependencies = "nvim-lua/plenary.nvim",
  },

  "typicode/bg.nvim",

  {
    "norcalli/nvim-colorizer.lua",
    keys = {
      { "<leader>tc", "<cmd>ColorizerToggle<cr>", desc = "Toggle colorizer" }
    },
    config = function()
      require("colorizer").setup()
    end,
  },

  { "folke/zen-mode.nvim" },
}
