local group = require("defaults").group
local dap, dapui = require("dap"), require("dapui")
dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

if group.plugins.dap_python then
  local dp_ok, dap_python = pcall(require, "dap-python")
  if dp_ok then dap_python.setup("~/.conda/debugpy/bin/python") end
end

local md_ok, mason_nvim_dap = pcall(require, "mason-nvim-dap")
if md_ok then
  mason_nvim_dap.setup({
    ensure_installed = require("defaults").ensure_installed.dap,
  })
end

dapui.setup({})
require("nvim-dap-virtual-text").setup({})
require("dap-lldb").setup({
  codelldb_path = "/Users/chilly/.local/share/nvim/mason/bin/codelldb",
})
