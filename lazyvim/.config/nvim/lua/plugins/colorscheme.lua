return {
  {
    "folke/tokyonight.nvim",
    name = "tokyonight",
    lazy = false,
    priority = 1000,
    opts = {
      terminal_colors = true,
      -- styles = {
      --   floats = "dark",
      -- },
    },
  },
  {
    "xiyaowong/nvim-transparent",
    enabled = true,
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
      exclude_groups = {}, -- table: groups you don't want to clear
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-night",
    },
  },
}
