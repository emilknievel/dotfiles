local base16_theme = os.getenv("BASE16_THEME")

local colorscheme = function()
  local theme_name = base16_theme and base16_theme:match("solarized") and "solarized"
    or base16_theme and base16_theme:match("catppuccin") and "catppuccin"
    or base16_theme and base16_theme:match("rose%-pine") and "rose-pine"
    or "tokyonight"

  return theme_name
end

return {
  {
    "folke/tokyonight.nvim",
    name = "tokyonight",
    opts = {
      style = "night",
      transparent = true,
      styles = {
        floats = "normal",
      },
    },
  },
  { "rose-pine/neovim", name = "rose-pine", opts = { disable_background = true } },
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
      transparent_background = true,
      highlight_overrides = {
        all = function(colors)
          return {
            NormalFloat = { bg = colors.mantle },
          }
        end,
      },
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
  {
    "rcarriga/nvim-notify",
    opts = {
      background_colour = vim.api.nvim_get_hl(0, { name = "Normal" }).bg and "Normal" or "#000000",
    },
  },
}
