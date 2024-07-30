return {
  { 'tpope/vim-dispatch' },
  { 'clojure-vim/vim-jack-in' },
  { 'radenling/vim-dispatch-neovim' },
  {
    -- interactive code evaluation
    'Olical/conjure',
    ft = {
      'clojure',
      'fennel',
      'janet',
      'racket',
      'scheme',
      'hy',
      'lisp',
    },
    init = function()
      require 'user.plugins.custom.conjure'
    end,
    config = function()
      require('conjure.main').main()
      require('conjure.mapping')['on-filetype']()
    end,
    dependencies = { 'PaterJason/cmp-conjure' },
  },
  {
    -- parinfer for Neovim
    'gpanders/nvim-parinfer',
    init = function()
      vim.g.parinfer_filetypes = my.lisps

      -- https://github.com/gpanders/nvim-parinfer/issues/12
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('FixShiftJForParinfer', {}),
        pattern = my.lisps,
        callback = function()
          vim.keymap.set('n', 'J', 'A<Space><Esc>J', { desc = 'fix J for parinfer' })
          vim.keymap.set('n', 'gJ', 'A<Space><Esc>gJ', { desc = 'fix gJ for parinfer' })
        end,
      })
    end,
  },
}
