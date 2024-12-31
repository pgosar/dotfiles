return {
	"nvimtools/none-ls.nvim",
	cond = group.plugins.none_ls,
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local null_ls = require("null-ls")
		require("mason").setup()
		null_ls.setup({
			sources = require("defaults").setup_sources(null_ls.builtins),
		})
	end,
	dependencies = {
		{
			"jay-babu/mason-null-ls.nvim",
			cmd = { "NullLsInstall", "NullLsUninstall" },
			opts = {
				ensure_installed = require("defaults").ensure_installed.null_ls,
				automatic_installation = true,
			},
		},
	},
}