local base16_theme = os.getenv("BASE16_THEME")

local colorscheme = function()
  local theme_name = base16_theme and base16_theme:match("tokyo%-night") and "tokyonight"
    or base16_theme and base16_theme:match("solarized") and "solarized"
    or base16_theme and base16_theme:match("catppuccin") and "catppuccin"
    or "gruvbox"

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
        dark = base16_theme and base16_theme:match("mocha") and "mocha" or base16_theme and base16_theme:match(
          "macchiato"
        ) and "macchiato" or base16_theme and base16_theme:match("frappe") and "frappe",
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
