local colorscheme = function()
  local base16_theme = os.getenv("BASE16_THEME")
  local theme_name = base16_theme and base16_theme:match("tokyo%-night") and "tokyonight" or "catppuccin"
  return theme_name
end

return {
  { "rose-pine/neovim", name = "rose-pine" },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      background = {
        light = "latte",
        dark = "mocha",
      },
      -- transparent_background = true,
    },
  },
  {
    "maxmx03/solarized.nvim",
    name = "solarized",
    lazy = false,
    priority = 1000,
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
  --     background_colour = "#000000",
  --   },
  -- },
}
