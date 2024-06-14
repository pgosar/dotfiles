return {
	"nvimtools/none-ls.nvim",
	cond = group.plugins.null_ls,
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local null_ls = require("null-ls")
		local ok, defaults = pcall(require, "defaults")
		if not ok then
			vim.api.nvim_err_writeln("Failed to load defaults.lua")
		end

		require("mason").setup()
		null_ls.setup({
			sources = defaults.setup_sources(null_ls.builtins),
		})
	end,
	dependencies = {
		{
			"jay-babu/mason-null-ls.nvim",
			cmd = { "NullLsInstall", "NullLsUninstall" },
			config = function()
				local ok, defaults = pcall(require, "defaults")
				if not ok then
					vim.api.nvim_err_writeln("Failed to load defaults.lua")
				end

				require("mason-null-ls").setup({
					ensure_installed = defaults.ensure_installed.null_ls,
					automatic_installation = true,
				})
			end,
		},
	},
}
