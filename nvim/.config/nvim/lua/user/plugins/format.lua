return {
  { -- Autoformat
    'stevearc/conform.nvim',
    lazy = false,
    -- '<leader>f' format keymap moved to lua/user/keymaps.lua (section "Format")
    config = function() require('user.plugins.config.conform') end,
  },
}
