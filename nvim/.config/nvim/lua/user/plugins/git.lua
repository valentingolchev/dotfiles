return {
  {
    -- https://github.com/lewis6991/gitsigns.nvim
    'lewis6991/gitsigns.nvim',
    config = function() require('user.plugins.config.gitsigns') end,
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
    config = function() require('user.plugins.config.neogit') end,
  },
}
