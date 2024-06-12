return {
	"mfussenegger/nvim-dap",
	cond = group.plugins.dap,
	event = "VeryLazy",
	config = function()
		require("plugin-configs.dap")
	end,
	dependencies = {
		{
			"mfussenegger/nvim-dap-python",
			ft = "python",
			cond = group.plugins.dap_python,
			config = function()
				require("plugin-configs.dap-python")
			end,
		},
		{
			"jay-babu/mason-nvim-dap.nvim",
			cmd = { "DapInstall", "DapUninstall" },
			config = function()
				require("plugin-configs.mason-nvim-dap")
			end,
		},
		{
			"rcarriga/nvim-dap-ui",
			config = true,
		},
		{
			"theHamsta/nvim-dap-virtual-text",
			config = true,
		},
		{
			"nvim-neotest/nvim-nio",
		},
	},
}
