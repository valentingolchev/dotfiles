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

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

map('n', '<leader>ntt', ':tabnew | term', { desc = 'Open [New] [T]erminal in a new [Tab].' })

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

-- paste in visual mode without replacing register content
map('v', 'p', [['pgv' . v:register . 'y']], { noremap = true, expr = true })

-- keep selection while shifting
map('v', '>', '>gv')
map('v', '<', '<gv')

map('n', '<space><space>x', '<cmd>source %<CR>', { desc = 'Source the current buffer.' })
