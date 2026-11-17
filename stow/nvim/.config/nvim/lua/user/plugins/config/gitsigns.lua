-- https://github.com/lewis6991/gitsigns.nvim
require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
  -- Keymaps live in lua/user/keymaps.lua (M.gitsigns_on_attach)
  on_attach = function(bufnr)
    require('user.keymaps').gitsigns_on_attach(bufnr)
  end,
}
