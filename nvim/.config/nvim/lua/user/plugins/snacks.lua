return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  config = function() require('user.plugins.config.snacks') end,
  -- All keymaps live in lua/user/keymaps.lua (section "Snacks picker").
}
