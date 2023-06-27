vim.opt.cursorline = true

if vim.fn.has "termguicolors" == 1 then
  vim.opt.termguicolors = true
else
  vim.opt.termguicolors = false
end

vim.opt.winblend = 0
vim.opt.wildoptions = "pum"
vim.opt.pumblend = 5
vim.opt.background = "dark"
