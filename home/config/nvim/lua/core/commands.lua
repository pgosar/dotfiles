-- Custom user commands
-- update function
vim.api.nvim_create_user_command(
  "CyberUpdate",
  function() require("core.utils.utils").update_all() end,
  { desc = "Updates plugins, mason packages, treesitter parsers" }
)

-- close buffer windows without messing up layout
vim.api.nvim_create_user_command(
  "Bd",
  function() require("snacks").bufdelete() end,
  { desc = "Delete buffer with Snacks" }
)

-- Lazy loaded plugins stub commands

local M = {}

local function load_neotree()
  vim.cmd("packadd nui.nvim")
  vim.cmd("packadd neo-tree.nvim")
  require("core.configs.neotree")
end

M.load_neotree = load_neotree

vim.api.nvim_create_user_command("FzfLua", function(opts)
  vim.cmd("packadd fzf-lua")
  require("core.configs.fzf")
  vim.cmd("FzfLua " .. opts.args)
end, { nargs = "*", complete = "file" })

vim.api.nvim_create_user_command("Neotree", function(opts)
  load_neotree()
  vim.cmd("Neotree " .. opts.args)
end, { nargs = "*", complete = "file" })

vim.api.nvim_create_user_command("Trouble", function(opts)
  vim.cmd("packadd trouble.nvim")
  require("core.configs.trouble")
  vim.cmd("Trouble " .. opts.args)
end, { nargs = "*", complete = "file" })

vim.api.nvim_create_user_command("ToggleVenn", function()
  vim.cmd("packadd venn.nvim")
  require("core.configs.venn")
end, { nargs = 0, desc = "Toggle venn" })

-- Mason command stub (for direct execution from dashboard)
vim.api.nvim_create_user_command("Mason", function(opts)
  vim.cmd("packadd mason.nvim")
  require("mason").setup()
  vim.cmd("Mason " .. opts.args)
end, { nargs = "*" })

-- Neogen command stub
vim.api.nvim_create_user_command("Neogen", function(opts)
  vim.cmd("packadd neogen")
  require("core.configs.neogen")
  vim.cmd("Neogen " .. opts.args)
end, { nargs = "*" })

-- Neotest command stub
vim.api.nvim_create_user_command("Neotest", function(opts)
  vim.cmd("packadd nvim-nio")
  vim.cmd("packadd neotest")
  require("core.configs.neotest")
  vim.cmd("Neotest " .. opts.args)
end, { nargs = "*", complete = "file" })

-- DAP commands stubs
local function load_dap_and_run(cmd_name, args)
  local dap_plugins = {
    "nvim-nio",
    "nvim-dap",
    "nvim-dap-ui",
    "nvim-dap-virtual-text",
    "nvim-dap-lldb",
    "nvim-dap-python",
    "mason-nvim-dap.nvim",
  }
  for _, p in ipairs(dap_plugins) do
    vim.cmd("packadd " .. p)
  end
  require("core.configs.dap")
  vim.cmd(cmd_name .. " " .. (args or ""))
end

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

return M
