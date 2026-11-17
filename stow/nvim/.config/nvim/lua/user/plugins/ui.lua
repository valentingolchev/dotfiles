return {
  { 'tpope/vim-sleuth' }, -- Detect tabstop and shiftwidth automatically
  { 'tpope/vim-repeat' },
  {
    -- https://github.com/nvim-lualine/lualine.nvim
    'nvim-lualine/lualine.nvim',
    config = function() require('user.plugins.config.lualine') end,
  },
}
