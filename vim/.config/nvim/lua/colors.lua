vim.opt.cursorline = true

if vim.fn.has('termguicolors') == 1 then
  vim.opt.termguicolors = true
else
  vim.opt.termguicolors = false
end

vim.opt.winblend = 0
vim.opt.wildoptions = 'pum'
vim.opt.pumblend = 5
vim.opt.background = 'dark'

-- highlight columns past 80
--vim.wo.colorcolumn = vim.fn.join(vim.fn.range(81,999),',')
vim.wo.colorcolumn = '81'

-- set contrast "hard, medium(default), soft"
-- vim.g.gruvbox_material_background = 'medium'

-- for better performance
-- vim.g.gruvbox_material_better_performance = 1

-- vim.cmd('colorscheme gruvbox-material')

-- Rose pine
require('rose-pine').setup({
  --- @usage 'main' | 'moon'
  dark_variant = 'main',
  bold_vert_split = false,
  dim_nc_background = false,
  disable_background = true,
  disable_float_background = false,
  disable_italics = true,

  --- @usage string hex value or named color from rosepinetheme.com/palette
  groups = {
    background = 'base',
    panel = 'surface',
    border = 'highlight_med',
    comment = 'muted',
    link = 'iris',
    punctuation = 'subtle',

    error = 'love',
    hint = 'iris',
    info = 'foam',
    warn = 'gold',

    headings = {
      h1 = 'iris',
      h2 = 'foam',
      h3 = 'rose',
      h4 = 'gold',
      h5 = 'pine',
      h6 = 'foam',
    },
    -- or set all headings at once
    -- headings = 'subtle'
  },

  -- Change specific vim highlight groups
  highlight_groups = {
    ColorColumn = { bg = 'surface' },
  },
})
-- vim.cmd('colorscheme rose-pine')

-- Catppuccin
require('catppuccin').setup({
  flavour = 'mocha', -- latte, frappe, macchiato, mocha
  background = { -- :h background
    light = 'latte',
    dark = 'mocha',
  },
  transparent_background = true,
  term_colors = false,
  dim_inactive = {
    enabled = false,
    shade = 'dark',
    percentage = 0.15,
  },
  no_italic = true, -- Force no italic
  no_bold = true, -- Force no bold
  styles = {
    comments = { 'italic' },
    conditionals = { 'italic' },
    loops = {},
    functions = {},
    keywords = {},
    strings = {},
    variables = {},
    numbers = {},
    booleans = {},
    properties = {},
    types = {},
    operators = {},
  },
  color_overrides = {},
  custom_highlights = {},
  integrations = {
    cmp = true,
    gitsigns = true,
    nvimtree = true,
    telescope = true,
    notify = false,
    mini = false,
    -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
  },
})
vim.cmd.colorscheme('catppuccin')
