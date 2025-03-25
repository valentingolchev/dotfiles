local home = os.getenv 'HOME'

-- use to check if jdtls, java-debug-adapter & java-test are installed
-- local mason_registry = require 'mason-registry'
local mason_path = require('mason.settings').current.install_root_dir
local mason_pkg_path = mason_path .. '/packages'
local jdtls_path = mason_pkg_path .. '/jdtls'
local lombok_jar = jdtls_path .. '/lombok.jar'

local root_dir = vim.fs.root(0, { '.git', 'mvnw', 'gradlew', 'pom.xml' })
local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
local workspace_dir = home .. '/.local/share/eclipse/' .. project_name

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

require('jdtls').start_or_attach {
  root_dir = root_dir,
  capabilities = capabilities,
  bundles = vim.split(vim.fn.glob(mason_pkg_path .. '/java-*/extension/server/*.jar', 1), '\n'),
  cmd = {
    vim.fn.expand(mason_path .. '/bin/jdtls'),
    '-configuration',
    jdtls_path .. '/config_mac',
    '--jvm-arg=-javaagent:' .. lombok_jar,
    '-data',
    workspace_dir,
  },
}
