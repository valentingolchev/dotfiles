return {
  {
    -- https://github.com/lewis6991/gitsigns.nvim
    'lewis6991/gitsigns.nvim',
    opts = {
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
    },
  },
  -- https://github.com/NeogitOrg/neogit
  {
    'NeogitOrg/neogit',
    dependencies = {
      -- required
      'nvim-lua/plenary.nvim',

      -- optional
      'sindrets/diffview.nvim',
    },
    config = function()
      local neogit = require 'neogit'

      neogit.setup {
        integrations = {
          snacks = true,
          diffview = true,
        },
      }

      -- '<localleader>ng' keymap moved to lua/user/keymaps.lua (section "Gitsigns"/neogit)
    end,
  },
}
