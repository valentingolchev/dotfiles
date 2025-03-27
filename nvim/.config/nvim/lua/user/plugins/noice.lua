return {
  {
    -- https://github.com/folke/noice.nvim
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      'MunifTanjim/nui.nvim',
      -- https://github.com/rcarriga/nvim-notify
      'rcarriga/nvim-notify',
    },
    config = function()
      require('noice').setup {}

      vim.notify = require 'notify'
    end,
  },
}
