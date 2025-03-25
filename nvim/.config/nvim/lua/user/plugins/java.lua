return {
  {
    'mfussenegger/nvim-jdtls',
    dependencies = 'hrsh7th/cmp-nvim-lsp',
  },
  { 'nvim-neotest/nvim-nio' },
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'antoinemadec/FixCursorHold.nvim',
      'rcasia/neotest-java',
    },
    config = function()
      require('neotest').setup {
        adapters = {
          require 'neotest-java',
        },
      }
    end,
  },
  {
    'mfussenegger/nvim-dap',
  },
  {
    'rcarriga/nvim-dap-ui',
    dependencies = 'mfussenegger/nvim-dap',
  },
}
