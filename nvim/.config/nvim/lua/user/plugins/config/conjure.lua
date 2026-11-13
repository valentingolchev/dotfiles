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

-- The conjure which-key buffer group and the `<prefix>cc` ConjureConnect map
-- moved to lua/user/keymaps.lua (section "Conjure")
