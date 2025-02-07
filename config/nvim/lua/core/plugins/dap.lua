return {
	"mfussenegger/nvim-dap",
	cond = group.plugins.dap,
  -- stylua: ignore
	keys = {
		{ "<leader>dc", function() require("dap").continue() end, desc = "Debugger Continue", },
		{ "<leader>dn", function() require("dap").step_over() end, desc = "Debugger Step Over", },
		{ "<leader>di", function() require("dap").step_into() end, desc = "Debugger Step Into", },
		{ "<leader>do", function() require("dap").step_out() end, desc = "Debugger Step Out", },
		{ "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint", },
		{ "<leader>dq", function() require("dap").disconnect({ terminateDebuggee = true }) end,
    desc = "Disconnect Debugger", },
	},
  -- stylua: ignore
	config = function()
		local dap, dapui = require("dap"), require("dapui")
		dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
		dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
		dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
	end,
	dependencies = {
		{
			"mfussenegger/nvim-dap-python",
			cond = group.plugins.dap_python,
			config = function()
				require("dap-python").setup("~/.conda/debugpy/bin/python")
			end,
		},
		{
			"jay-babu/mason-nvim-dap.nvim",
			cmd = { "DapInstall", "DapUninstall" },
			config = function()
				---@diagnostic disable-next-line: missing-fields
				require("mason-nvim-dap").setup({
					ensure_installed = require("defaults").ensure_installed.dap,
				})
			end,
		},
		{ "rcarriga/nvim-dap-ui", opts = {} },
		{ "theHamsta/nvim-dap-virtual-text", opts = {} },
		{ "nvim-neotest/nvim-nio" },
		{
			"julianolf/nvim-dap-lldb",
			opts = { codelldb_path = "/Users/chilly/.local/share/nvim/mason/bin/codelldb" },
		},
	},
}
