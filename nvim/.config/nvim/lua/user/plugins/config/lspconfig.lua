-- The LspAttach autocmd (buffer keymaps + highlight + inlay hints) moved to
-- lua/user/keymaps.lua (section "LSP")

-- update diagnostics in insert mode too
vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, { update_in_insert = true })
-- window border for hover float
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })
-- window border for the LSP info float
require('lspconfig.ui.windows').default_options.border = 'single'

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend('force', capabilities, require('blink.cmp').get_lsp_capabilities())

local servers = {
  lua_ls = {
    settings = {
      Lua = {
        completion = {
          callSnippet = 'Replace',
        },
        -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
        -- diagnostics = { disable = { 'missing-fields' } },
      },
    },
  },
  fennel_ls = {},
  clojure_lsp = {},
  jdtls = {},
  pylsp = {},
  bashls = {
    -- bashIde = {
    --   shellcheckPath = vim.fn.exepath("shellcheck") or "",
    --   enableDiagnostics = false,
    -- }
  },
  docker_language_server = {},
  jsonls = {},
  yamlls = {},
  terraformls = {},
  elp = {},
  dexter = {},
  -- expert = {},
  -- elixirls = {},
  -- protols = {},
  -- clangd = { filetypes = { 'c', 'cpp', 'objc', 'objcpp' } },
  -- ◍ stylua
  -- ◍ clj-kondo
  -- ◍ cljfmt
  -- ◍ java-debug-adapter
  -- ◍ java-test
}

require('mason').setup()
require('mason-lspconfig').setup {
  ensure_installed = vim.list_extend(vim.tbl_keys(servers or {}), {}),
  handlers = {
    function(server_name)
      if 'jdtls' == server_name then
        require 'notify'('Skipping lsp-config setup for language server: ' .. server_name)
        return
      end

      local server = servers[server_name] or {}
      server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
      require('lspconfig')[server_name].setup(server)
    end,
  },
}
