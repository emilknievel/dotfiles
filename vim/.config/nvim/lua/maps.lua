local keymap = vim.keymap

vim.g.mapleader = ' '

keymap.set('n', 'x', '"_x') -- remove character without putting into register

-- Increment/decrement
keymap.set('n', '<leader>+', '<C-a>')
keymap.set('n', '<leader>-', '<C-x>')

-- Delete a word backwards
-- keymap.set('n', 'dw', 'vb"_d')

-- Save with root permission (not working for now)
--vim.api.nvim_create_user_command('W', 'w !sudo tee > /dev/null %', {})

-- Tab management
keymap.set('n', '<leader>to', ':tabnew<CR>') -- open new tab
keymap.set('n', '<leader>tx', ':tabclose<CR>') -- close current tab
keymap.set('n', '<leader>tn', ':tabn<CR>') -- go to next tab
keymap.set('n', '<leader>tp', ':tabp<CR>') -- go to previous tab

-- Window management
keymap.set('n', '<leader>ss', ':split<Return><C-w>w') -- horizontally
keymap.set('n', '<leader>sv', ':vsplit<Return><C-w>w') -- vertically
keymap.set('n', '<leader>se', '<C-w>=') -- make split windows equal width
keymap.set('n', '<leader>sx', ':close<CR>') -- close currently split window


-- Select split window
-- keymap.set('n', '<Space>', '<C-w>w')
keymap.set('', '<leader>sh', '<C-w>h')
keymap.set('', '<leader>sk', '<C-w>k')
keymap.set('', '<leader>sj', 'C-w>j')
keymap.set('', '<leader>sl', '<C-w>l')

-- Resize window
keymap.set('n', '<C-w><left>', '<C-w><')
keymap.set('n', '<C-w><right>', '<C-w>>')
keymap.set('n', '<C-w><up>', '<C-w>+')
keymap.set('n', '<C-w><down>', '<C-w>-')
