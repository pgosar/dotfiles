-- Custom OSC 52 clipboard provider (only used if no working system clipboard tool is found)
local function has_working_clipboard()
  if vim.fn.executable("pbcopy") == 1 then
    return true
  end
  if vim.fn.executable("wl-copy") == 1 and vim.env.WAYLAND_DISPLAY ~= nil and vim.env.WAYLAND_DISPLAY ~= "" then
    return true
  end
  if (vim.fn.executable("xclip") == 1 or vim.fn.executable("xsel") == 1) and vim.env.DISPLAY ~= nil and vim.env.DISPLAY ~= "" then
    return true
  end
  if vim.fn.executable("clip.exe") == 1 then
    return true
  end
  if vim.fn.executable("termux-clipboard-set") == 1 then
    return true
  end
  return false
end

if not has_working_clipboard() then
  vim.g.clipboard = {
    name = 'OSC 52',
    copy = {
      ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
      ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
    },
    paste = {
      ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
      ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
    },
  }
end

-- Global editor options
local vim_opts = require("core.utils.utils").vim_opts
vim.opt.shortmess:append("sIW")

vim_opts({
  opt = {
    autowrite = true, -- Auto save before commands
    clipboard = "unnamedplus", -- Use system clipboard
    conceallevel = 3, -- Hide concealed text
    confirm = true, -- Confirm save changes
    cursorline = true, -- Highlight cursor line
    cursorlineopt = "number", -- Highlight cursor line number
    foldenable = true, -- Enable folding
    foldexpr = "v:lua.vim.treesitter.foldexpr()", -- Treesitter folding
    foldcolumn = "0", -- Disable fold column
    foldlevel = 99, -- Set fold level
    foldlevelstart = 99, -- Start with all folds open
    foldmethod = "expr", -- Fold based on expression
    foldopen = "jump,block,hor,mark,percent,quickfix,search,tag,undo", -- Commands that open folds
    guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20", -- Cursor settings
    hidden = true, -- Allow buffer switching without saving
    ignorecase = true, -- Ignore case in search
    laststatus = 3, -- Global statusline
    linebreak = true, -- Break lines at word boundaries
    number = true, -- Show line numbers
    numberwidth = 6, -- Width of number column
    pumheight = 10, -- Auto-complete menu max height
    report = 9999, -- Silence 'fewer lines' etc. reports
    scrolloff = 5, -- Lines above/below cursor
    sessionoptions = "blank,buffers,curdir,help,tabpages,winsize,winpos,terminal,localoptions,folds", -- Session options
    shiftwidth = 2, -- Spaces per indent
    softtabstop = 2, -- Spaces per <Tab>
    tabstop = 2, -- Spaces per tab
    expandtab = true, -- turn tabs to spaces
    showbreak = "=>>", -- Wrapped line prefix
    breakindent = true,
    showmode = false, -- Hide mode in command line
    smartcase = true, -- Smart case search
    spell = true, -- Enable spell check
    spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add", -- Custom spell file
    spelllang = "en_us", -- Spell check language
    termguicolors = true, -- 24-bit RGB colors
    textwidth = 100, -- Max text width
    undofile = true, -- Persistent undo
    updatetime = 100, -- Faster completion
  },
  g = {
    mapleader = " ",
  },
})

local defaults = require("defaults")
if defaults.group.plugins.virt_column then
  vim.opt.colorcolumn = defaults.plugin_settings.virt_column
end

-- Ensure spell directory and file exist on fresh install
local spell_dir = vim.fn.stdpath("config") .. "/spell"
local spell_path = spell_dir .. "/en.utf-8.add"
if vim.fn.isdirectory(spell_dir) == 0 then vim.fn.mkdir(spell_dir, "p") end
if vim.fn.filereadable(spell_path) == 0 then
  local f = io.open(spell_path, "w")
  if f then
    f:write("")
    f:close()
  end
end
