-- Core init using native vim pack package manager

-- Disable default plugins early to optimize startup time
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_gzip = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_tohtml = 1
vim.g.loaded_tutor_mode_plugin = 1

-- 1. Define custom vim.notify wrapper early to capture any startup notifications
local original_notify = vim.notify
---@diagnostic disable-next-line: duplicate-set-field
vim.notify = function(msg, level, opts)
  local ignore_patterns = {
    "Processing file symbols",
    "Diagnosing",
    "left == right",
    "-32603",
    "-32802",
  }
  for _, pattern in ipairs(ignore_patterns) do
    if msg and msg:find(pattern, 1, true) then return end
  end
  original_notify(msg, level, opts)
end

-- Load defaults and options
local ok, defaults = pcall(require, "defaults")
if not ok then vim.notify("Failed to load defaults.lua") end
_G.group = defaults.group
local big_file = require("core.utils.utils").large_file(vim.api.nvim_get_current_buf())

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

-- Native packages bootstrapper
local start_path = vim.fn.stdpath("config") .. "/pack/plugins/start"
local opt_path = vim.fn.stdpath("config") .. "/pack/plugins/opt"
vim.fn.mkdir(start_path, "p")
vim.fn.mkdir(opt_path, "p")

local plugins = require("core.plugins")
local needs_restart = false

for _, p in ipairs(plugins) do
  local p_dir = p.lazy and opt_path or start_path
  local p_path = p_dir .. "/" .. p.name
  if vim.fn.empty(vim.fn.glob(p_path)) > 0 then
    needs_restart = true
    vim.notify("Installing " .. p.name .. "...")
    local clone_cmd = { "git", "clone", "--depth=1", p.url, p_path }
    if p.name == "blink.cmp" then
      clone_cmd = { "git", "clone", "--depth=1", "--branch", "v1.10.2", p.url, p_path }
    end
    local obj = vim.system(clone_cmd):wait()
    if obj.code ~= 0 then
      vim.notify(
        string.format("Failed to install %s:\n%s", p.name, obj.stderr or "Unknown error"),
        vim.log.levels.ERROR
      )
    end
  end
end

-- Force load all start packages immediately so they are available in runtimepath
vim.cmd("packloadall")

if needs_restart then
  vim.notify("All plugins installed! Please restart Neovim.", vim.log.levels.INFO)
end

-- Load core modules
for _, source in ipairs({
  "core.main-options",
  "core.keybindings",
  "core.autocommands",
  "core.commands",
}) do
  if not big_file then
    local status_ok, fault = pcall(require, source)
    if not status_ok then vim.notify("Failed to load " .. source .. "\n\n" .. fault) end
  end
end

-- Custom rename function
vim.lsp.buf.rename = require("core.utils.rename").rename
-- Run plugin configurations
if not big_file then
  -- Load all non-lazy start configs
  for _, name in ipairs({
    "catppuccin",
    "treesitter",
    "dropbar",
    "lualine",
    "snacks",
    "surround",
    "whichkey",
    "ai",
    "align",
    "autopairs",
    "autotag",
    "bufferline",
    "multicursor",
  }) do
    local load_ok, err = pcall(require, "core.configs." .. name)
    if not load_ok then
      vim.notify("Failed to load config " .. name .. ": " .. tostring(err), vim.log.levels.ERROR)
    end
  end
end

-- Immediate load of Neo-tree if opened with a directory
if not big_file and vim.fn.argc() > 0 then
  local arg = vim.fn.argv(0)
  if type(arg) == "string" and arg ~= "" then
    local stats = vim.uv.fs_stat(arg)
    if stats and stats.type == "directory" then
      local cmd_ok, commands = pcall(require, "core.commands")
      if cmd_ok and commands.load_neotree then commands.load_neotree() end
    end
  end
end

-- Colorscheme setting
local color_ok, _ = pcall(vim.cmd.colorscheme, require("defaults").colorscheme)
if not color_ok then vim.cmd.colorscheme("default") end

-- Only update LSP diagnostics on insert leave
vim.diagnostic.config({
  update_in_insert = false,
})

-- DAP signs
vim.fn.sign_define("DapBreakpoint", { text = icons.dap.breakpoint })
vim.fn.sign_define("DapStopped", { text = icons.dap.stopped })

-- Set default border for floating windows
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
---@diagnostic disable-next-line: duplicate-set-field
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or "rounded"
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end
