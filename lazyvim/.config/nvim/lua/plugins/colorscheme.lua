local base16_theme = os.getenv("BASE16_THEME")

local colorscheme = function()
  local theme_name = base16_theme and base16_theme:match("solarized") and "solarized"
    or base16_theme and base16_theme:match("catppuccin") and "catppuccin"
    or base16_theme and base16_theme:match("rose%-pine") and "rose-pine"
    or base16_theme and base16_theme:match("kanagawa") and "kanagawa"
    or "tokyonight"
  return theme_name
end

return {
  {
    "folke/tokyonight.nvim",
    name = "tokyonight",
    opts = {
      style = "night",
      -- transparent = true,
      -- styles = {
      --   floats = "normal",
      -- },
    },
  },
  { "rose-pine/neovim", name = "rose-pine", opts = { disable_background = false } },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      background = {
        light = "frappe",
        dark = "mocha",
      },
      -- transparent_background = true,
      -- highlight_overrides = {
      --   all = function(colors)
      --     return {
      --       NormalFloat = { bg = colors.mantle },
      --     }
      --   end,
      -- },
    },
  },
  {
    "maxmx03/solarized.nvim",
    name = "solarized",
    priority = 1000,
  },
  {
    "rebelot/kanagawa.nvim",
    name = "kanagawa",
    priority = 1000,
    opts = {
      background = { -- wave, dragon, lotus
        dark = "dragon",
        light = "lotus",
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = colorscheme(),
    },
  },
  -- {
  --   "rcarriga/nvim-notify",
  --   opts = {
  --     background_colour = vim.api.nvim_get_hl(0, { name = "Normal" }).bg and "Normal" or "#000000",
  --   },
  -- },
}
