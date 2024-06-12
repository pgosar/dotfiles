return {
	"nvimtools/none-ls.nvim",
	cond = group.plugins.null_ls,
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("plugin-configs.null-ls")
	end,
	dependencies = {
		{
			"jay-babu/mason-null-ls.nvim",
			cmd = { "NullLsInstall", "NullLsUninstall" },
			config = function()
				require("plugin-configs.mason-null-ls")
			end,
		},
	},
}
