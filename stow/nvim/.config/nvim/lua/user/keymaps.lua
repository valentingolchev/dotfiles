local map = function(mode, lhs, rhs, opts)
  opts = opts or { silent = true }
  vim.keymap.set(mode, lhs, rhs, opts)
end

local M = {}

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

map({ 'n', 'v' }, '<Space>', '<Nop>')

-- Remap for dealing with word wrap
map('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

map('i', 'jj', '<Esc>', { desc = 'Exit insert mode', noremap = true })
map('i', 'jk', '<Esc>', { desc = 'Exit insert mode', noremap = true })
map('v', 'jk', '<Esc>', { desc = 'Exit visual mode', noremap = true })

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
map('n', '<Esc>', '<cmd>nohlsearch<CR>')
map('n', '<leader>h', ':nohlsearch<CR>')

-- Diagnostic keymaps
map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
map('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

map('n', '<leader>ntt', '<cmd>tabnew | term<CR>', { desc = 'Open [New] [T]erminal in a new [Tab].' })
map('n', '<leader>st', '<cmd>Floaterminal<CR>', { desc = 'Open [S]mall Floating [T]erminal.' })
map({ 'n', 'v' }, '<D-,>', '<cmd>Floaterminal<CR>', { desc = 'Open [S]mall Floating [T]erminal.' })
map('t', '<D-,>', '<C-\\><C-n><cmd>Floaterminal<CR>', { desc = 'Open [S]mall Floating [T]erminal.' })

vim.api.nvim_create_autocmd('TermOpen', {
  group = vim.api.nvim_create_augroup('custom-term-open', { clear = true }),
  callback = function()
    vim.opt.number = false
    vim.opt.relativenumber = false
  end,
})

-- keep selection while shifting
map('v', '>', '>gv')
map('v', '<', '<gv')

-- paste in visual mode without replacing register content (by default)
map('x', 'p', 'P', { noremap = true })
map('x', 'P', 'p', { noremap = true })

-- close all other folds but the current one (using the 'z' mark)
map('n', 'z<C-f>', "mzzM'zzxzz", { desc = 'focus the current fold' })

-- Dismiss Notification
map('n', '<leader>nd', function() Snacks.notifier.hide() end, { desc = 'Dismiss Notification' })

-- Open Zoxide
-- map('n', '<leader>Z', '<cmd>Zi<CR>', { desc = 'Open Zoxide' })

-- Resize with arrows
map('n', '<C-S-Down>', ':resize +2<CR>', { desc = 'Resize Horizontal Split Down' })
map('n', '<C-S-Up>', ':resize -2<CR>', { desc = 'Resize Horizontal Split Up' })
map('n', '<C-Left>', ':vertical resize -2<CR>', { desc = 'Resize Vertical Split Down' })
map('n', '<C-Right>', ':vertical resize +2<CR>', { desc = 'Resize Vertical Split Up' })

local mc_select = [[y/\V\C<C-r>=escape(@", '/')<CR><CR>]]

map('n', 'cn', '*``cgn', { desc = 'mc change word (forward)' })
map('n', 'cN', '*``cgN', { desc = 'mc change word (backward)' })
map('x', '<leader>cn', mc_select .. '``cgn', { desc = 'mc change selection (forward)' })
map('x', '<leader>cN', mc_select .. '``cgN', { desc = 'mc change selection (backward)' })

map('n', '<space><space>x', '<cmd>source %<CR>', { desc = 'Source the current buffer.' })

-- [[ Snacks picker ]]
-- Moved from lua/user/plugins/snacks.lua (`keys` block). snacks.nvim is eager
-- (lazy = false), so the `Snacks` global exists by the time these run.

-- Files / Grep
map('n', '<leader>sf', function() Snacks.picker.files() end, { desc = '[S]earch [F]iles' })
map('n', '<leader>sg', function() Snacks.picker.grep() end, { desc = '[S]earch [G]rep' })
map('n', '<leader>sw', function() Snacks.picker.grep_word() end, { desc = '[S]earch Grep [W]ord' })
map('n', '<leader>sb', function() Snacks.picker.buffers() end, { desc = '[S]earch [B]uffers' })
map('n', '<leader>sr', function() Snacks.picker.recent() end, { desc = '[S]earch [R]ecent' })
map('n', '<leader>sd', function() Snacks.picker.diagnostics() end, { desc = '[S]earch [D]iagnostics' })
map('n', '<leader>sh', function() Snacks.picker.help() end, { desc = '[S]earch [H]elp' })
map('n', '<leader>sk', function() Snacks.picker.keymaps() end, { desc = '[S]earch [K]eymaps' })
map('n', '<leader>/', function() Snacks.picker.lines() end, { desc = 'Buffer Lines' })
map('n', '<leader><leader>', function() Snacks.picker.buffers() end, { desc = 'Buffers' })

-- Grep variants
map('n', '<leader>s/', function() Snacks.picker.grep({ buffers = true }) end, { desc = 'Grep Open Files' })
map('n', '<leader>smg', function()
  vim.ui.input({ prompt = 'Glob (empty=all): ' }, function(glob)
    if glob == nil then return end
    local opts = (glob ~= '') and { glob = glob } or {}
    Snacks.picker.grep(opts)
  end)
end, { desc = 'Multigrep (pattern + glob)' })

-- Config / Plugins
map('n', '<leader>sn', function() Snacks.picker.files({ cwd = vim.fn.stdpath('config') }) end, { desc = 'Nvim Config' })
map('n', '<leader>sp', function() Snacks.picker.files({ cwd = vim.fs.joinpath(vim.fn.stdpath('data'), 'lazy') }) end, { desc = 'Plugins' })
map('n', '<leader>:', function() Snacks.picker.commands() end, { desc = 'Command Palette' })

-- Git pickers (bonus)
map('n', '<leader>gb', function() Snacks.picker.git_branches() end, { desc = 'Git Branches' })
map('n', '<leader>gs', function() Snacks.picker.git_status() end, { desc = 'Git Status' })
map('n', '<leader>gl', function() Snacks.picker.git_log() end, { desc = 'Git Log' })

-- Snacks extras
map('n', '<leader>un', function() Snacks.notifier.show_history() end, { desc = 'Notification History' })
map('n', '<leader>z', function() Snacks.zen() end, { desc = 'Zen Mode' })
map('n', '<leader>Z', function() Snacks.zen.zoom() end, { desc = 'Zoom' })

-- Images / Mermaid
map('n', '<leader>im', function()
  vim.g.mermaid_unsandboxed = true
  Snacks.notify('Rendering images', { title = 'Markdown' })
  -- Real buffer number: snacks looks up windows by it, and 0 matches none.
  Snacks.image.doc.attach(vim.api.nvim_get_current_buf())
end, { desc = 'Render images and mermaid in buffer' })

-- [[ Trouble ]]
-- Moved from lua/user/plugins/trouble.lua (`keys` block); plugin spec keeps
-- `cmd = 'Trouble'` so the <cmd> rhs lazy-loads it.

map('n', '<leader>xw', '<cmd>Trouble diagnostics toggle<CR>', { desc = 'Open trouble workspace diagnostics' })
map('n', '<leader>xd', '<cmd>Trouble diagnostics toggle filter.buf=0<CR>', { desc = 'Open trouble document diagnostics' })
map('n', '<leader>xq', '<cmd>Trouble quickfix toggle<CR>', { desc = 'Open trouble quickfix list' })
map('n', '<leader>xl', '<cmd>Trouble loclist toggle<CR>', { desc = 'Open trouble location list' })
map('n', '<leader>xt', '<cmd>Trouble todo toggle<CR>', { desc = 'Open todos in trouble' })

-- [[ Format (conform) ]]
-- Moved from lua/user/plugins/format.lua (`keys` block).

map({ 'n', 'v', 'x', 's', 'o' }, '<leader>f', function()
  require('conform').format { async = true, lsp_fallback = true }
end, { desc = '[F]ormat buffer' })

-- [[ Oil file explorer ]]
-- Global map to open oil.
map('n', '-', '<cmd>Oil<CR>', { desc = 'Open files explorer' })

-- Buffer-local oil maps, moved from the `keymaps` table in
-- lua/user/plugins/oil.lua. oil.nvim resolves 'actions.xxx' strings via
-- require('oil.actions') (see oil/lua/oil/keymap_util.lua), and it sets its
-- default buffer keymaps *after* the FileType autocmd fires (view.initialize),
-- so schedule our overrides to run after oil's.
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'oil',
  group = vim.api.nvim_create_augroup('user-oil-keymaps', { clear = true }),
  callback = function(ev)
    local actions = require 'oil.actions'

    -- Wrap an oil action and its optional opts table as a keymap rhs
    local function action(name, action_opts)
      return function()
        actions[name].callback(action_opts)
      end
    end

    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(ev.buf) then
        return
      end

      local map_buf = function(lhs, name, action_opts, desc)
        map('n', lhs, action(name, action_opts), { buffer = ev.buf, desc = desc })
      end
      local del_buf = function(lhs)
        pcall(vim.api.nvim_buf_del_keymap, ev.buf, 'n', lhs)
      end

      map_buf('g?', 'show_help', nil, 'Show default keymaps')
      map_buf('<CR>', 'select', nil, 'Open the entry under the cursor')
      del_buf('<C-s>')
      map_buf('gv', 'select', { vertical = true }, 'Open the entry under the cursor in a vertical split')
      del_buf('<C-h>')
      map_buf('gh', 'select', { horizontal = true }, 'Open the entry under the cursor in a horizontal split')
      map_buf('<C-t>', 'select', { tab = true }, 'Open the entry under the cursor in a new tab')
      map_buf('<C-p>', 'preview', nil, 'Open the entry under the cursor in a preview window, or close the preview window if already open')
      map_buf('<C-c>', 'close', nil, 'Close oil and restore original buffer')
      del_buf('<C-l>')
      map_buf('<C-r>', 'refresh', nil, 'Refresh current directory list')
      map_buf('-', 'parent', nil, 'Navigate to the parent path')
      map_buf('_', 'open_cwd', nil, "Open oil in Neovim's current working directory")
      map_buf('`', 'cd', nil, ':cd to the current oil directory')
      map_buf('~', 'cd', { scope = 'tab' }, ':tcd to the current oil directory')
      map_buf('gs', 'change_sort', nil, 'Change the sort order')
      map_buf('gx', 'open_external', nil, 'Open the entry under the cursor in an external program')
      map_buf('g.', 'toggle_hidden', nil, 'Toggle hidden files and directories')
      map_buf('g\\', 'toggle_trash', nil, 'Jump to and from the trash for the current directory')
    end)
  end,
})

-- [[ DAP ]]
-- Moved from lua/user/plugins/dap.lua. Kept AFTER the Snacks section so
-- '<leader>gb' keeps resolving to dap.run_to_cursor (dap won the previous
-- load-order race).

map('n', '<leader>db', function() require('nvim-dap').toggle_breakpoint() end)
map('n', '<leader>dr', function() require('nvim-dap').restart() end)
map('n', '<leader>gb', function() require('nvim-dap').run_to_cursor() end)
map('n', '<leader>dc', function() require('nvim-dap').continue() end)

-- Eval var under cursor
map('n', '<space>?', function()
  require('dapui').eval(nil, { enter = true })
end)

map('n', '<leader>1', function() require('nvim-dap').continue() end)
map('n', '<leader>2', function() require('nvim-dap').step_into() end)
map('n', '<leader>3', function() require('nvim-dap').step_over() end)
map('n', '<leader>4', function() require('nvim-dap').step_out() end)
map('n', '<leader>5', function() require('nvim-dap').step_back() end)
map('n', '<F13>', function() require('nvim-dap').restart() end)

-- [[ LSP ]]
-- Moved from lua/user/plugins/config/lspconfig.lua (single LspAttach autocmd).

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    map('gd', function() Snacks.picker.lsp_definitions() end, '[G]oto [D]efinition')
    map('gr', function() Snacks.picker.lsp_references() end, '[G]oto [R]eferences')
    map('gI', function() Snacks.picker.lsp_implementations() end, '[G]oto [I]mplementation')
    map('<leader>D', function() Snacks.picker.lsp_type_definitions() end, 'Type [D]efinition')
    map('<leader>ds', function() Snacks.picker.lsp_symbols() end, '[D]ocument [S]ymbols')
    map('<leader>ws', function() Snacks.picker.lsp_workspace_symbols() end, '[W]orkspace [S]ymbols')
    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    map('K', vim.lsp.buf.hover, 'Hover Documentation')

    -- WARN: This is not Goto Definition, this is Goto Declaration.
    --  For example, in C this would take you to the header.
    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    -- The following two autocommands are used to highlight references of the
    -- word under your cursor when your cursor rests there for a little while.
    --    See `:help CursorHold` for information about when this is executed
    --
    -- When you move your cursor, the highlights will be cleared (the second autocommand).
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.server_capabilities.documentHighlightProvider then
      local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
        end,
      })
    end

    -- The following autocommand is used to enable inlay hints in your
    -- code, if the language server you are using supports them
    --
    -- This may be unwanted, since they displace some of your code
    if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
      map('<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
      end, '[T]oggle Inlay [H]ints')
    end
  end,
})

-- [[ Gitsigns ]]
-- on_attach body moved from lua/user/plugins/git.lua; the plugin spec
-- delegates via require('user.keymaps').gitsigns_on_attach(bufnr).

M.gitsigns_on_attach = function(bufnr)
  local gitsigns = require 'gitsigns'

  local function map(mode, l, r, opts)
    opts = opts or {}
    opts.buffer = bufnr
    vim.keymap.set(mode, l, r, opts)
  end

  -- Navigation
  map('n', ']c', function()
    if vim.wo.diff then
      vim.cmd.normal { ']c', bang = true }
    else
      gitsigns.nav_hunk 'next'
    end
  end, { desc = 'Jump to next git [c]hange' })

  map('n', '[c', function()
    if vim.wo.diff then
      vim.cmd.normal { '[c', bang = true }
    else
      gitsigns.nav_hunk 'prev'
    end
  end, { desc = 'Jump to previous git [c]hange' })

  -- Actions
  -- visual mode
  map('v', '<leader>hs', function()
    gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
  end, { desc = 'Git (un)[s]tage hunk' })
  map('v', '<leader>hr', function()
    gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
  end, { desc = 'Git [r]eset hunk' })
  -- normal mode
  map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'Git (un)[s]tage hunk' })
  map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'Git [r]eset hunk' })
  map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'Git [S]tage buffer' })
  map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'Git [R]eset buffer' })
  map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'Git [p]review hunk' })
  map('n', '<leader>hpi', gitsigns.preview_hunk_inline, { desc = 'Git [p]review hunk inline' })
  map('n', '<leader>hb', gitsigns.blame_line, { desc = 'Git [b]lame line' })
  map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git [b]lame line' })
  map('n', '<leader>hd', gitsigns.diffthis, { desc = 'Git [d]iff against index' })
  map('n', '<leader>hD', function()
    gitsigns.diffthis '@'
  end, { desc = 'Git [D]iff against last commit' })
  -- Toggles
end

-- Neogit (moved from lua/user/plugins/git.lua)
map('n', '<localleader>ng', '<cmd>Neogit<cr>', { desc = 'Open [N]eo[G]it status window' })

-- [[ Harpoon ]]
-- Global maps moved from lua/user/plugins/harpoon.lua.

map('n', '<C-e>', function()
  local harpoon = require 'harpoon'
  harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = 'Open harpoon window' })

map('n', '<leader>a', function()
  local harpoon = require 'harpoon'
  harpoon:list():add()
end, { desc = 'Add file to Harpoon list' })

map('n', '<leader>A', function()
  local harpoon = require 'harpoon'
  harpoon:list():remove()
end, { desc = 'Remove file from Harpoon list' })

-- map('n', '<C-h>', function() require('harpoon'):list():select(1) end)
-- map('n', '<C-t>', function() require('harpoon'):list():select(2) end)
-- map('n', '<C-n>', function() require('harpoon'):list():select(3) end)
-- map('n', '<C-s>', function() require('harpoon'):list():select(4) end)

-- Toggle previous & next buffers stored within Harpoon list
map('n', '<C-p>', function()
  local harpoon = require 'harpoon'
  harpoon:list():prev()
end)
map('n', '<C-n>', function()
  local harpoon = require 'harpoon'
  harpoon:list():next()
end)

-- Buffer maps inside the harpoon quick menu, delegated from the UI_CREATE
-- extension in lua/user/plugins/harpoon.lua.
M.harpoon_ui_create = function(cx)
  local harpoon = require 'harpoon'

  map('n', '<C-v>', function()
    harpoon.ui:select_menu_item { vsplit = true }
  end, { buffer = cx.bufnr })

  map('n', '<C-x>', function()
    harpoon.ui:select_menu_item { split = true }
  end, { buffer = cx.bufnr })

  map('n', '<C-t>', function()
    harpoon.ui:select_menu_item { tabedit = true }
  end, { buffer = cx.bufnr })
end

-- [[ Conjure ]]
-- FileType autocmd moved verbatim from lua/user/plugins/config/conjure.lua
-- (which-key buffer group + connect map). Relies on the `my` global from
-- lua/user/config.lua, required before this file in init.lua.

-- experimental mapping for now, lets see how (and if) this evolves
local conjure_prefix = ','

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
        prefix = vim.g['conjure#mapping#prefix'] or conjure_prefix,
        buffer = opts.buf,
      })

      vim.keymap.set('n', conjure_prefix .. 'cc', ':ConjureConnect ', { buffer = opts.buf, desc = 'Connect to port' })
    end
  end,
})

-- [[ Parinfer J fix ]]
-- FileType autocmd moved from lua/user/plugins/clojure.lua (nvim-parinfer
-- `init`); see https://github.com/gpanders/nvim-parinfer/issues/12

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('FixShiftJForParinfer', {}),
  pattern = my.lisps,
  callback = function()
    map('n', 'J', 'A<Space><Esc>J', { desc = 'fix J for parinfer' })
    map('n', 'gJ', 'A<Space><Esc>gJ', { desc = 'fix gJ for parinfer' })
  end,
})

-- [[ Claude Code ]]
-- Key STRINGS for claude-code.nvim, consumed by lua/user/plugins/claude.lua
-- (the plugin has no `keymaps = false` escape hatch, so its internal
-- vim.keymap.set calls stay plugin-internal; only the strings live here).

M.claude_keymaps = {
  normal = '<C-,>', -- Normal mode keymap for toggling Claude Code
  terminal = '<C-,>', -- Terminal mode keymap for toggling Claude Code
  continue = '<leader>cC', -- Normal mode keymap for Claude Code with continue flag
  verbose = '<leader>cV', -- Normal mode keymap for Claude Code with verbose flag
}

-- [[ Which-key groups ]]
-- Group registrations moved from lua/user/plugins/which-key.lua. The plugin
-- spec is lazy (event = 'VimEnter'), so register the groups when which-key
-- actually loads instead of requiring it eagerly here.

vim.api.nvim_create_autocmd('User', {
  pattern = 'LazyLoad',
  callback = function(args)
    if args.data ~= 'which-key.nvim' then
      return
    end
    local wk = require 'which-key'

    -- Document existing key chains
    wk.add {
      { '<leader>c', desc = '[C]ode' },
      { '<leader>d', desc = '[D]ocument' },
      { '<leader>g', desc = '[G]it' },
      { '<leader>h', desc = 'Git [H]unk' },
      { '<leader>r', desc = '[R]ename' },
      { '<leader>s', desc = '[S]earch' },
      { '<leader>w', desc = '[W]orkspace' },
      { '<leader>t', desc = '[T]oggle' },
      {
        mode = { 'v' },
        { '<leader>h', desc = 'Git [H]unk' },
      },
    }

    -- visual mode
    wk.add({}, { mode = 'v' })
  end,
})

return M
