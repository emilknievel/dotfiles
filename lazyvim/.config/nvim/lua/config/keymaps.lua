-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function toggle_theme()
  if vim.o.background == "light" then
    vim.cmd("set background=dark")
    vim.cmd("colorscheme catppuccin")
  else
    vim.cmd("set background=light")
    vim.cmd("colorscheme tokyonight")
  end
end

vim.keymap.set("n", "<leader>tt", toggle_theme, { desc = "Toggle theme" })
vim.keymap.set("i", "jj", "<Esc>")
