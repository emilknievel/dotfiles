local status, saga = pcall(require, 'lspsaga')
if not status then return end

saga.init_lsp_saga({
  -- server_filetype_map = {
  --   typescript = 'typescript'
  -- }
})

local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<C-j>', '<Cmd>Lspsaga diagnostic_jump_next<CR>', opts)
vim.keymap.set('n', 'K', '<Cmd>Lspsaga hover_doc<CR>', opts)
vim.keymap.set('n', 'gd', '<Cmd>Lspsaga lsp_finder<CR>', opts)
vim.keymap.set('i', '<C-k>', '<Cmd>Lspsaga signature_help<CR>', opts)
vim.keymap.set('n', 'gp', '<Cmd>Lspsaga peek_definition<CR>', opts)
vim.keymap.set('n', '<leader>vrn', '<Cmd>Lspsaga rename<CR>', opts)
vim.keymap.set('n', 'cd', '<Cmd>Lspsaga show_line_diagnostics<CR>', opts)
vim.keymap.set('n', 'cd', '<Cmd>Lspsaga show_cursor_diagnostics<CR>', opts)
vim.keymap.set('n', '[d', '<cmd>Lspsaga diagnostic_jump_prev<CR>', opts)
vim.keymap.set('n', ']d', '<cmd>Lspsaga diagnostic_jump_next<CR>', opts)

-- Float terminal
vim.keymap.set('n', '<A-d>', '<cmd>Lspsaga open_floaterm<CR>', opts)
-- close floaterm
vim.keymap.set(
  't',
  '<A-d>',
  [[<C-\><C-n><cmd>Lspsaga close_floaterm<CR>]],
  opts
)

-- Code action
vim.keymap.set(
  { 'n', 'v' },
  '<leader>ca',
  '<cmd>Lspsaga code_action<CR>',
  { silent = true }
)
