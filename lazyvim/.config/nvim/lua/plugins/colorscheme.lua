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
  { "p00f/alabaster.nvim" },
  { "nyoom-engineering/oxocarbon.nvim" },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "oxocarbon",
    },
  },
}
