-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.tabstop = 8
vim.opt.spelllang = { "en", "sv" }

if os.getenv("TERM_THEME") == "dark" then
  vim.opt.background = "dark"
else
  vim.opt.background = "light"
end
