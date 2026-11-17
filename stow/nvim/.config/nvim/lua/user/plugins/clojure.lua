return {
  { 'tpope/vim-dispatch' },
  { 'clojure-vim/vim-jack-in' },
  { 'radenling/vim-dispatch-neovim' },
  {
    -- parinfer for Neovim
    'gpanders/nvim-parinfer',
    init = function() require('user.plugins.config.parinfer') end,
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
    init = function() require 'user.plugins.config.conjure' end,
    config = function() require('user.plugins.config.conjure').setup() end,
  },
}
