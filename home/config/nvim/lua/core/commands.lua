-- Custom user commands
-- update function
vim.api.nvim_create_user_command(
  "CyberUpdate",
  function() require("core.utils.utils").update_all() end,
  { desc = "Updates plugins, mason packages, treesitter parsers" }
)

-- Toggle between light and dark theme mode
vim.api.nvim_create_user_command("CyberThemeToggle", function()
  vim.o.background = (vim.o.background == "dark") and "light" or "dark"
  -- Clear cached theme_colors so it returns the new palette
  package.loaded["theme_colors"] = nil
  package.loaded["theme_colors_generated"] = nil
  -- Reload colorscheme; the BgSync autocmd applies theme background
  local colorscheme = vim.g.colors_name
  if colorscheme then
    vim.cmd("colorscheme " .. colorscheme)
  end
  vim.notify("Theme mode: " .. vim.o.background)
end, { desc = "Toggle light/dark theme mode" })

-- Sync editor background from theme_colors after colorscheme loads.
-- Ensures Neovim background is independent of terminal background.
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("ThemeBgSync", { clear = true }),
  callback = function()
    local ok, theme = pcall(require, "theme_colors")
    if ok and theme and theme.base then
      vim.api.nvim_set_hl(0, "Normal", { bg = theme.base })
      vim.api.nvim_set_hl(0, "NormalNC", { bg = theme.base })
      vim.api.nvim_set_hl(0, "SignColumn", { bg = theme.base })
    end
  end,
})

-- close buffer windows without messing up layout
local M = {}
local plugins = require("core.utils.plugins")

if plugins.enabled("snacks") and plugins.enabled("snack_bufdelete") then
  vim.api.nvim_create_user_command(
    "Bd",
    function() require("snacks").bufdelete() end,
    { desc = "Delete buffer with Snacks" }
  )
end

-- Lazy loaded plugins stub commands

local function load_neotree() return plugins.load("neotree") end

M.load_neotree = load_neotree

if plugins.enabled("fzf") then
  vim.api.nvim_create_user_command("FzfLua", function(opts)
    if not plugins.load("fzf") then return end
    vim.cmd("FzfLua " .. opts.args)
  end, { nargs = "*", complete = "file" })
end

if plugins.enabled("neotree") then
  vim.api.nvim_create_user_command("Neotree", function(opts)
    if not load_neotree() then return end
    vim.cmd("Neotree " .. opts.args)
  end, { nargs = "*", complete = "file" })
end

if plugins.enabled("trouble") then
  vim.api.nvim_create_user_command("Trouble", function(opts)
    if not plugins.load("trouble") then return end
    vim.cmd("Trouble " .. opts.args)
  end, { nargs = "*", complete = "file" })
end

if plugins.enabled("venn") then
  vim.api.nvim_create_user_command("ToggleVenn", function()
    -- Re-run the toggle script; require alone would return the cached module
    package.loaded["core.configs.venn"] = nil
    plugins.load("venn")
  end, { nargs = 0, desc = "Toggle venn" })
end

-- Mason command stub (for direct execution from dashboard)
if plugins.enabled("mason") then
  vim.api.nvim_create_user_command("Mason", function(opts)
    if not plugins.load("mason") then return end
    vim.cmd("Mason " .. opts.args)
  end, { nargs = "*" })
end

-- Neogen command stub
if plugins.enabled("neogen") then
  vim.api.nvim_create_user_command("Neogen", function(opts)
    if not plugins.load("neogen") then return end
    vim.cmd("Neogen " .. opts.args)
  end, { nargs = "*" })
end

-- Neotest command stub
if plugins.enabled("neotest") then
  vim.api.nvim_create_user_command("Neotest", function(opts)
    if not plugins.load("neotest") then return end
    vim.cmd("Neotest " .. opts.args)
  end, { nargs = "*", complete = "file" })
end

-- DAP commands stubs
local function load_dap_and_run(cmd_name, args)
  if not plugins.load("dap") then return end
  vim.cmd(cmd_name .. " " .. (args or ""))
end

if plugins.enabled("dap") then
  for _, cmd in ipairs({
    "DapContinue",
    "DapToggleBreakpoint",
    "DapStepOver",
    "DapStepInto",
    "DapStepOut",
    "DapTerminate",
  }) do
    vim.api.nvim_create_user_command(
      cmd,
      function(opts) load_dap_and_run(cmd, opts.args) end,
      { nargs = "*" }
    )
  end
end

return M
