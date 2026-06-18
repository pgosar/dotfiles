local group = require("defaults").group
local dap = require("dap")

if group.plugins.dap_ui then
  local dapui = require("dapui")
  dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
  dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
  dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
  dapui.setup({})
end

if group.plugins.dap_python then
  local dp_ok, dap_python = pcall(require, "dap-python")
  if dp_ok then dap_python.setup("~/.conda/debugpy/bin/python") end
end

local md_ok, mason_nvim_dap = false, nil
if group.plugins.mason_nvim_dap then
  md_ok, mason_nvim_dap = pcall(require, "mason-nvim-dap")
end
local mason_nvim_dap_setup = type(mason_nvim_dap) == "table" and mason_nvim_dap["setup"]
if md_ok and type(mason_nvim_dap_setup) == "function" then
  mason_nvim_dap_setup({
    ensure_installed = require("defaults").ensure_installed.dap,
  })
end

if group.plugins.dap_virtual_text then require("nvim-dap-virtual-text").setup({}) end

if group.plugins.dap_lldb then
  require("dap-lldb").setup({
    codelldb_path = "/Users/chilly/.local/share/nvim/mason/bin/codelldb",
  })
end
