return {
  -- https://github.com/kevinhwang91/nvim-bqf
  {
    'kevinhwang91/nvim-bqf',
    enabled = false,
    config = function()
      require('bqf').setup()
    end,
  },
  -- https://github.com/stevearc/quicker.nvim
  {
    'stevearc/quicker.nvim',
    event = 'FileType qf',
    ---@module "quicker"
    ---@type quicker.SetupOptions
    opts = {},
  },
}
