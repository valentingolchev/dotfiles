return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons", "folke/todo-comments.nvim" },
  cmd = "Trouble",
  config = function() require('user.plugins.config.trouble') end,
  -- Keymaps moved to lua/user/keymaps.lua (section "Trouble")
}
