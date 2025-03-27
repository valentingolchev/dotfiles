local map = function(mode, lhs, rhs, opts)
  opts = opts or { silent = true }
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

map({ 'n', 'v' }, '<Space>', '<Nop>')

-- Remap for dealing with word wrap
map('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
map('n', '<Esc>', '<cmd>nohlsearch<CR>')
map('n', '<leader>h', ':nohlsearch<CR>')

-- Diagnostic keymaps
map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
map('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

map('n', '<leader>ntt', ':tabnew | term<CR>', { desc = 'Open [New] [T]erminal in a new [Tab].' })

map('n', '<leader>st', function()
  vim.cmd.vnew()
  vim.cmd.term()
  vim.cmd.wincmd 'J'
  vim.api.nvim_win_set_height(0, 10)
end, { desc = 'Open [S]mall [T]erminal.' })

vim.api.nvim_create_autocmd('TermOpen', {
  group = vim.api.nvim_create_augroup('custom-term-open', { clear = true }),
  callback = function()
    vim.opt.number = false
    vim.opt.relativenumber = false
  end,
})

-- keep selection while shifting
map('v', '>', '>gv')
map('v', '<', '<gv')

-- paste in visual mode without replacing register content (by default)
map('x', 'p', 'P', { noremap = true })
map('x', 'P', 'p', { noremap = true })

-- close all other folds but the current one (using the 'z' mark)
map('n', 'z<C-f>', "mzzM'zzxzz", { desc = 'focus the current fold' })

-- Dismiss Noice Message
map('n', '<leader>nd', '<cmd>NoiceDismiss<CR>', { desc = 'Dismiss Noice Message' })

-- Open Zoxide telescope extension
map('n', '<leader>Z', '<cmd>Zi<CR>', { desc = 'Open Zoxide' })

-- Resize with arrows
map('n', '<C-S-Down>', ':resize +2<CR>', { desc = 'Resize Horizontal Split Down' })
map('n', '<C-S-Up>', ':resize -2<CR>', { desc = 'Resize Horizontal Split Up' })
map('n', '<C-Left>', ':vertical resize -2<CR>', { desc = 'Resize Vertical Split Down' })
map('n', '<C-Right>', ':vertical resize +2<CR>', { desc = 'Resize Vertical Split Up' })

local mc_select = [[y/\V\C<C-r>=escape(@", '/')<CR><CR>]]

map('n', 'cn', '*``cgn', { desc = 'mc change word (forward)' })
map('n', 'cN', '*``cgN', { desc = 'mc change word (backward)' })
map('x', '<leader>cn', mc_select .. '``cgn', { desc = 'mc change selection (forward)' })
map('x', '<leader>cN', mc_select .. '``cgN', { desc = 'mc change selection (backward)' })

map('n', '<space><space>x', '<cmd>source %<CR>', { desc = 'Source the current buffer.' })

map('n', '-', '<cmd>Oil<CR>', { desc = 'Open files explorer' })
