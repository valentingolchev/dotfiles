-- The LspAttach autocmd (buffer keymaps + highlight + inlay hints) moved to
-- lua/user/keymaps.lua (section "LSP")

-- update diagnostics in insert mode too (0.11+ native API; vim.lsp.diagnostic.* is gone on 0.13)
vim.diagnostic.config { update_in_insert = true }

-- window border for hover float (no vim.lsp.with — deprecated/removed on nightly)
local default_hover = vim.lsp.handlers['textDocument/hover']
vim.lsp.handlers['textDocument/hover'] = function(err, result, ctx, config)
  default_hover(err, result, ctx, vim.tbl_extend('force', config or {}, { border = 'rounded' }))
end
-- NOTE: old `require('lspconfig.ui.windows').default_options.border = 'single'` dropped — module is a dead stub in lspconfig v3; hover border covered above.

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend('force', capabilities, require('blink.cmp').get_lsp_capabilities())
vim.lsp.config('*', { capabilities = capabilities })

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
  jdtls = {}, -- set up by java.lua, do not auto-enable (java.lua currently fully commented out — kept excluded to preserve old behavior)
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

-- per-server config (merged with lsp/<server>.lua defaults from nvim-lspconfig runtimepath if present)
for server, cfg in pairs(servers) do
  if server ~= 'jdtls' then
    cfg.capabilities = vim.tbl_deep_extend('force', {}, capabilities, cfg.capabilities or {})
    vim.lsp.config(server, cfg)
  end
end

-- install server binaries via mason; do NOT let mason-lspconfig call lspconfig setup (dead on nightly)
-- mason-lspconfig v2 removed the `handlers` setting; disable its automatic vim.lsp.enable so
-- enabling stays explicit below (and jdtls stays excluded).
require('mason').setup()
require('mason-lspconfig').setup {
  ensure_installed = vim.list_extend(vim.tbl_keys(servers or {}), {}),
  automatic_enable = false, -- install only
}

-- enable servers natively (jdtls excluded — handled by java.lua)
local enabled = vim.tbl_filter(function(s) return s ~= 'jdtls' end, vim.tbl_keys(servers))
vim.lsp.enable(enabled)
