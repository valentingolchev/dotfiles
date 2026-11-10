-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- This file has to be loaded BEFORE the conjure plugin NOT afterwards
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

vim.g['conjure#filetypes'] = my.lisps
vim.g['conjure#filetype#fennel'] = 'conjure.client.fennel.stdio'

-- check the JackIn/JackInBB command in ftplugin/after/clojure.lua
vim.g['conjure#client#clojure#nrepl#eval#auto_require`'] = false
vim.g['conjure#client#clojure#nrepl#connection#auto_repl#enabled'] = false

-- experimental mapping for now, lets see how (and if) this evolves
local conjure_prefix = ','
vim.g['conjure#mapping#prefix'] = conjure_prefix
vim.g['conjure#mapping#doc_word'] = { '<M-k>' } -- avoid conflict with LSP mapping

-- add custom prefix labels for which-key
vim.api.nvim_create_autocmd('FileType', {
  pattern = my.lisps,
  callback = function(opts)
    if vim.api.nvim_buf_is_loaded(opts.buf) then
      require('which-key').add({
        name = 'Conjure',
        { 'c', desc = 'Connect' },
        { 'e', desc = 'Evaluate' },
        { 'ec', desc = 'Comment' },
        { 'g', desc = 'Get' },
        { 'l', desc = 'Logs' },
        { 'r', desc = 'Refresh' },
        { 's', desc = 'Session' },
        { 't', desc = 'Tests' },
        { 'v', desc = 'View' },
      }, {
        prefix = vim.g['conjure#mapping#prefix'],
        buffer = opts.buf,
      })

      vim.keymap.set('n', conjure_prefix .. 'cc', ':ConjureConnect ', { buffer = opts.buf, desc = 'Connect to port' })
    end
  end,
})
