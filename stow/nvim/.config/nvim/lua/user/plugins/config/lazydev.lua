---@module 'lazydev'
---@type lazydev.Config
local opts = {
  library = {
    { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
  },
}

require('lazydev').setup(opts)
