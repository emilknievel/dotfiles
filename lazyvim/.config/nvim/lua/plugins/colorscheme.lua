local colorscheme = function()
  local base16_theme = os.getenv("BASE16_THEME")
  local background = vim.api.nvim_get_option("background")

  local theme_name = base16_theme and base16_theme:match("solarized") and "solarized"
    or base16_theme and base16_theme:match("catppuccin") and "catppuccin"
    or base16_theme and base16_theme:match("rose%-pine") and "rose-pine"
    or base16_theme and base16_theme:match("tokyo%-night") and "tokyonight"
    or base16_theme and base16_theme:match("kanagawa") and "kanagawa"
    or background == "light" and "modus-operandi"
    or background == "dark" and "modus-vivendi"
    or "modus-vivendi"

  if theme_name and theme_name:match("modus") then
    vim.g.modus_termtrans_enable = 1
  end

  return theme_name
end

return {
  {
    "folke/tokyonight.nvim",
    name = "tokyonight",
    opts = {
      background = {
        light = "day",
        dark = "night",
      },
      transparent = true,
      styles = {
        floats = "normal",
      },
    },
  },
  { "rose-pine/neovim", name = "rose-pine", opts = { disable_background = false } },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      background = {
        light = "latte",
        dark = "mocha",
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
    "ishan9299/modus-theme-vim",
    priority = 1000,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = colorscheme(),
    },
  },
}
