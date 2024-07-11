return {
  { 'tpope/vim-sleuth' }, -- Detect tabstop and shiftwidth automatically
  { 'tpope/vim-repeat' },
  {
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = '|',
        section_separators = '',
      },
    },
  },
}
