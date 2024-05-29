local dap_ok, _ = pcall(require, "dap")

if dap_ok then
	require("dap-python").setup("~/.conda/debugpy/bin/python")
end
