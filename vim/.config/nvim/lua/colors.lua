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

-- set contrast "hard, medium(default), soft"
vim.g.gruvbox_material_background = 'medium'

-- for better performance
vim.g.gruvbox_material_better_performance = 1

vim.cmd('colorscheme gruvbox-material')
