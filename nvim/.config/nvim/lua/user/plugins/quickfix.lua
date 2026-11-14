return {
  -- https://github.com/stevearc/quicker.nvim
  {
    'stevearc/quicker.nvim',
    event = 'FileType qf',
    config = function() require('user.plugins.config.quicker') end,
  },
}
