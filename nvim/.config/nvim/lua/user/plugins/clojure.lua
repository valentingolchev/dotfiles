return {
  { 'tpope/vim-dispatch' },
  { 'clojure-vim/vim-jack-in' },
  { 'radenling/vim-dispatch-neovim' },
  {
    -- parinfer for Neovim
    'gpanders/nvim-parinfer',
    init = function()
      vim.g.parinfer_filetypes = my.lisps

      -- https://github.com/gpanders/nvim-parinfer/issues/12
      -- The 'J'/'gJ' keymaps from this autocmd moved to lua/user/keymaps.lua
      -- (section "Parinfer J fix")
    end,
  },
  {
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
    lazy = true,
    init = function()
      require 'user.plugins.config.conjure'
    end,
    config = function()
      require('conjure.main').main()
      require('conjure.mapping')['on-filetype']()
    end,
  },
}
