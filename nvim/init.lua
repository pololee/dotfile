-- Enable line numbers
vim.opt.number = true

-- Enable linebreak at word boundaries
vim.opt.linebreak = true

-- Set the string to show before wrapped lines
vim.opt.showbreak = "+++"

-- Set maximum text width
vim.opt.textwidth = 80

-- Show matching parentheses
vim.opt.showmatch = true

-- Use visual bell instead of beeping
vim.opt.visualbell = true

-- Enable mouse support
vim.opt.mouse = 'a'

-- Highlight all search matches
vim.opt.hlsearch = true

-- Enable smart case search
vim.opt.smartcase = true

-- Ignore case in search patterns
vim.opt.ignorecase = true

-- Enable incremental search
vim.opt.incsearch = true

-- Enable automatic indentation
vim.opt.autoindent = true

-- Use spaces instead of tabs
vim.opt.expandtab = true

-- Set the number of spaces for indentation
vim.opt.shiftwidth = 2

-- Enable smart indentation
vim.opt.smartindent = true

-- Make tab insert spaces according to shiftwidth
vim.opt.smarttab = true

-- Set the number of spaces for a tab
vim.opt.softtabstop = 2

-- Enable the ruler (shows cursor position)
vim.opt.ruler = true

-- Set the number of undo levels
vim.opt.undolevels = 1000

-- Configure the backspace behavior
vim.opt.backspace = { 'indent', 'eol', 'start' }

-- Set the background to dark
vim.opt.background = 'dark'

-- Enable command-line completion with a menu
vim.opt.wildmenu = true

-- Enable syntax highlighting
vim.cmd('syntax on')

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    { 
      "catppuccin/nvim", 
      name = "catppuccin", 
      priority = 1000,
      config = function()
        vim.cmd([[colorscheme catppuccin]])
      end,
    }
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})
