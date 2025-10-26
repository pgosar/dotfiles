local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

local ok, defaults = pcall(require, "defaults")
if not ok then
  vim.api.nvim_err_writeln("Failed to load defaults.lua")
end
_G.group = defaults.group
local big_file = require("core.utils.utils").large_file(vim.api.nvim_get_current_buf())

for _, source in ipairs({
  "core.main-options",
  "core.keybindings",
  "core.utils.notify",
  "core.autocommands",
}) do
  if not big_file then
    local status_ok, fault = pcall(require, source)
    if not status_ok then
      vim.api.nvim_err_writeln("Failed to load " .. source .. "\n\n" .. fault)
    end
  end
end

if not big_file then
  require("lazy").setup("core/plugins", {
    defaults = { lazy = true },
    performance = {
      rtp = {
        disabled_plugins = { "tohtml", "gzip", "zipPlugin", "netrwPlugin", "tarPlugin" },
      },
    },
  })
end

if group.plugins.notify then
  _, vim.notify = pcall(require, "notify")
end

-- update function
vim.api.nvim_create_user_command("CyberUpdate", function()
  require("core.utils.utils").update_all()
end, { desc = "Updates plugins, mason packages, treesitter parsers" })

-- setup spellcheck
local spell_words = {}
for word in io.open(vim.fn.stdpath("config") .. "/spell/en.utf-8.add", "r"):lines() do
  table.insert(spell_words, word)
end

local color_ok, _ = pcall(vim.cmd.colorscheme, require("defaults").colorscheme)
if not color_ok then
  vim.cmd.colorscheme("default")
end

-- only update LSP diagnostic information when leaving insert mode
vim.diagnostic.config({
  update_in_insert = false,
})

-- set essential options if file is very big
if big_file then
  local vim_opts = require("core.utils.utils").vim_opts
  vim_opts({
    opt = {
      autowrite = true,
      undofile = true,
      clipboard = "unnamedplus",
      cursorline = true,
      cursorlineopt = "number",
      ignorecase = true,
      laststatus = 3,
      number = true,
      scrolloff = 5,
      foldlevel = 99,
      foldlevelstart = 99,
      softtabstop = 2,
    },
  })
end

local sign = vim.fn.sign_define
sign("DiagnosticSignError", { text = icons.diagnostics.error, texthl = "DiagnosticSignError" })
sign("DiagnosticSignWarn", { text = icons.diagnostics.warn, texthl = "DiagnosticSignWarn" })
sign("DiagnosticSignInfo", { text = icons.diagnostics.info, texthl = "DiagnosticSignInfo" })
sign("DiagnosticSignHint", { text = icons.diagnostics.hint, texthl = "DiagnosticSignHint" })
sign("DapBreakpoint", { text = icons.dap.breakpoint })
sign("DapStopped", { text = icons.dap.stopped })
