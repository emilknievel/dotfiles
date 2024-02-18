-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.tabstop = 8
vim.opt.spelllang = { "en", "sv" }
local term_theme = os.getenv("TERM_THEME")
vim.opt.background = term_theme == "light" and "light" or "dark"
