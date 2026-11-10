-- Mermaid renders in an unsandboxed Chromium (AppArmor blocks its sandbox), so
-- it only runs on demand. Without the flag, mmdc keeps the sandbox and fails,
-- which also covers buffers snacks attaches on its own, like picker previews.
local function mermaid_args()
  local theme = vim.o.background == 'light' and 'neutral' or 'dark'
  local args = { '-i', '{src}', '-o', '{file}', '-b', 'transparent', '-t', theme, '-s', '{scale}' }
  if vim.g.mermaid_unsandboxed then
    vim.list_extend(args, { '-p', vim.fn.stdpath 'config' .. '/mermaid-puppeteer.json' })
  end
  return args
end

return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    picker = { enabled = true },
    input = { enabled = true },
    dashboard = {
      enabled = true,
      width = 80,
      preset = {
        header = [[
                                                                        
                                              ⣿                         
       ⣿████⣿ ⣿██████⣿           ⣿█████⣿      ⣿██⣿                       
      ⣿██████⣿⣿█████⣿             ⣿█████⣿ ⣿                             
      ⣿███████⣿⣿██⣿ ⣿████████⣿⣿███⣿⣿█████⣿███ ███⣿   ⣿███⣿████⣿████⣿    
     ⣿█⣿⣿████████⣿  ⣿███⣿    ⣿█████⣿⣿████████ █████ █████⣿████⣿█████    
    ⣿███⣿⣿██████⣿ ⣿████████⣿⣿██⣿ ⣿██⣿⣿███████ █████ █████ ████ █████    
  ⣿██████⣿⣿█████⣿ ⣿███⣿    ⣿███⣿ ⣿███⣿⣿██████ █████ █████ ████ █████⣿   
 ⣿██████⣿  ⣿███⣿⣿█████████⣿⣿█████████⣿ ⣿████⣿ █████ █████ ████ ██████⣿  
                                                                        
        ]],
      },
      sections = {
        { section = 'header' },
        { section = 'keys', gap = 1, padding = 1 },
        { section = 'recent_files', limit = 5, padding = 1 },
        { section = 'startup' },
        {
          footer = 'NVIM v' .. tostring(vim.version()),
          padding = 1,
        },
      },
    },
    notifier = { enabled = true },
    indent = { enabled = true },
    bigfile = { enabled = true },
    words = { enabled = true },
    scroll = { enabled = true },
    image = {
      enabled = true,
      doc = { enabled = false },
      convert = { notify = true, mermaid = mermaid_args },
    },
  },
  keys = {
    -- Files / Grep
    { '<leader>sf', function() Snacks.picker.files() end, desc = 'Find Files' },
    { '<leader>sg', function() Snacks.picker.grep() end, desc = 'Grep' },
    { '<leader>sw', function() Snacks.picker.grep_word() end, desc = 'Grep Word' },
    { '<leader>sb', function() Snacks.picker.buffers() end, desc = 'Buffers' },
    { '<leader>sr', function() Snacks.picker.recent() end, desc = 'Recent' },
    { '<leader>sd', function() Snacks.picker.diagnostics() end, desc = 'Diagnostics' },
    { '<leader>sh', function() Snacks.picker.help() end, desc = 'Help' },
    { '<leader>sk', function() Snacks.picker.keymaps() end, desc = 'Keymaps' },
    { '<leader>/', function() Snacks.picker.lines() end, desc = 'Buffer Lines' },
    { '<leader><leader>', function() Snacks.picker.buffers() end, desc = 'Buffers' },

    -- Grep variants
    { '<leader>s/', function() Snacks.picker.grep({ buffers = true }) end, desc = 'Grep Open Files' },
    { '<leader>smg', function()
      vim.ui.input({ prompt = 'Glob (empty=all): ' }, function(glob)
        if glob == nil then return end
        local opts = (glob ~= '') and { glob = glob } or {}
        Snacks.picker.grep(opts)
      end)
    end, desc = 'Multigrep (pattern + glob)' },

    -- Config / Plugins
    { '<leader>sn', function() Snacks.picker.files({ cwd = vim.fn.stdpath('config') }) end, desc = 'Nvim Config' },
    { '<leader>sp', function() Snacks.picker.files({ cwd = vim.fs.joinpath(vim.fn.stdpath('data'), 'lazy') }) end, desc = 'Plugins' },
    { '<leader>:', function() Snacks.picker.commands() end, desc = 'Command Palette' },

    -- Git pickers (bonus)
    { '<leader>gb', function() Snacks.picker.git_branches() end, desc = 'Git Branches' },
    { '<leader>gs', function() Snacks.picker.git_status() end, desc = 'Git Status' },
    { '<leader>gl', function() Snacks.picker.git_log() end, desc = 'Git Log' },

    -- Snacks extras
    { '<leader>un', function() Snacks.notifier.show_history() end, desc = 'Notification History' },
    { '<leader>z', function() Snacks.zen() end, desc = 'Zen Mode' },
    { '<leader>Z', function() Snacks.zen.zoom() end, desc = 'Zoom' },

    -- Images / Mermaid
    {
      '<leader>im',
      function()
        vim.g.mermaid_unsandboxed = true
        Snacks.notify('Rendering images', { title = 'Markdown' })
        -- Real buffer number: snacks looks up windows by it, and 0 matches none.
        Snacks.image.doc.attach(vim.api.nvim_get_current_buf())
      end,
      desc = 'Render images and mermaid in buffer',
    },
  },
}
