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
  -- All keymaps live in lua/user/keymaps.lua (section "Snacks picker").
}
