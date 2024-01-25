local keymap = vim.keymap

vim.g.mapleader = " "

keymap.set("n", "x", '"_x') -- remove character without putting into register

-- Increment/decrement
keymap.set("n", "<leader>+", "<cmd><C-a><CR>", { desc = "Increment" })
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement" })

-- Delete a word backwards
-- keymap.set('n', 'dw', 'vb"_d')

-- Save with root permission (not working for now)
--vim.api.nvim_create_user_command('W', 'w !sudo tee > /dev/null %', {})

-- Tab management
-- keymap.set('n', '<leader>to', ':tabnew<CR>', { desc = 'New tab' })
-- keymap.set('n', '<leader>tx', ':tabclose<CR>', { desc = 'Close tab' })
-- keymap.set('n', '<leader>tn', ':tabn<CR>', { desc = 'Next tab' })
-- keymap.set('n', '<leader>tp', ':tabp<CR>', { desc = 'Previous tab' })

-- Window management
-- keymap.set('n', '<leader>ss', ':split<Return><C-w>w', { desc = 'HSplit' })
-- keymap.set('n', '<leader>sv', ':vsplit<Return><C-w>w', { desc = 'VSplit' })
-- keymap.set('n', '<leader>se', '<C-w>=', { desc = 'Split equal width' })
-- keymap.set('n', '<leader>sx', ':close<CR>', { desc = 'Close current split' })

-- Select split window
-- keymap.set('n', '<Space>', '<C-w>w')
-- keymap.set('', '<leader>sh', '<C-w>h', { desc = 'Left split' })
-- keymap.set('', '<leader>sk', '<C-w>k', { desc = 'Above split' })
-- keymap.set('', '<leader>sj', 'C-w>j', { desc = 'Below split' })
-- keymap.set('', '<leader>sl', '<C-w>l', { desc = 'Right split' })

-- Resize window
keymap.set("n", "<C-w><left>", "<C-w><", { desc = "Grow window left" })
keymap.set("n", "<C-w><right>", "<C-w>>", { desc = "Grow window right" })
keymap.set("n", "<C-w><up>", "<C-w>+", { desc = "Grow window up" })
keymap.set("n", "<C-w><down>", "<C-w>-", { desc = "Grow window down" })

-- Vertical movement
keymap.set("n", "<C-d>", "<C-d>zz") -- Center view after moving down half a page
keymap.set("n", "<C-u>", "<C-u>zz") -- Center view after moving up half a page

keymap.set("n", "n", "nzzzv")       -- Center view when going forwards through search results
keymap.set("n", "N", "Nzzzv")       -- Center view when going backwards through search results

-- move selected text up and down
keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected text down" })
keymap.set("v", "K", ":m '>-2<CR>gv=gv", { desc = "Move selected text up" })

-- append line below to current line with space in between. Keep cursor pos
keymap.set("n", "J", "mzJ`z", {
  desc = "Append line below to end of caret line with spaces in between. Keep cursor pos.",
})

-- delete highlighted word and paste previous text in buffer
keymap.set("x", "<leader>p", '"_dP', { desc = "Delete highlighted word and paste previous text in buffer" })

-- yank with leader to copy to system clipboard
keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Copy to system clipboard" })
keymap.set("n", "<leader>Y", [["+Y]], { desc = "Copy current line to system clipboard" })

-- delete to void register
keymap.set("n", "<leader>d", "'_d", { desc = "Delete to void register" })
keymap.set("v", "<leader>d", "'_d", { desc = "Delete to void register" })

keymap.set("n", "Q", "<nop>") -- never want to press 'Q'

-- keymap.set('n', '<leader>f', function() vim.lsp.buf.format() end)

-- quickfix navigation
keymap.set("n", "<C-K>", "<cmd>cnext<CR>zz")
keymap.set("n", "<C-J>", "<cmd>cprev<CR>zz")
keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- replace current word in buffer
keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>//g<Left><Left>]], { desc = "Replace current word in buffer" })

-- make current file executable
keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make current file executable" })

keymap.set("n", "<leader>ws", function()
  vim.opt.list = not vim.opt.list:get()
  print("Display whitespace: " .. tostring(vim.opt.list:get()))
end, { desc = "Toggle displaying whitespace" })

-- jj to escape
keymap.set("i", "jj", "<Esc>", { noremap = false })

vim.keymap.set("n", "<leader>gdo", "<cmd>DiffviewOpen<CR>")
vim.keymap.set("n", "<leader>gdc", "<cmd>DiffviewClose<CR>")
