return {
  {
    "xiyaowong/nvim-transparent",
    enabled = false,
    opts = {
      groups = { -- table: default groups
        "Normal",
        "NormalNC",
        "Comment",
        "Constant",
        "Special",
        "Identifier",
        "Statement",
        "PreProc",
        "Type",
        "Underlined",
        "Todo",
        "String",
        "Function",
        "Conditional",
        "Repeat",
        "Operator",
        "Structure",
        "LineNr",
        "NonText",
        "SignColumn",
        "CursorLine",
        "CursorLineNr",
        "StatusLine",
        "StatusLineNC",
        "EndOfBuffer",
      },
      extra_groups = {}, -- table: additional groups that should be cleared
      exclude_groups = { "NotifyBackground" }, -- table: groups you don't want to clear
    },
  },
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = true,
    opts = {
      transparent_mode = true,
      overrides = {
        NotifyBackground = { bg = "#ff9900" },
      },
    },
  },
  {
    "maxmx03/solarized.nvim",
    priority = 1000,
  },
  -- {
  --   "LazyVim/LazyVim",
  --   opts = {
  --     colorscheme = "solarized",
  --   },
  -- },
}
