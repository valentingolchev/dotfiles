return {
  -- "gc" to comment visual regions/lines
  {
    'numToStr/Comment.nvim',
    config = function() require('user.plugins.config.comment') end,
  },

  -- Highlight todo, notes, etc in comments
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function() require('user.plugins.config.todo-comments') end,
  },
}
