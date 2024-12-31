return {
	{
		"nvim-treesitter/nvim-treesitter",
		cond = group.plugins.treesitter,
		build = ":TSUpdate",
		lazy = false,
		config = function()
			require("nvim-treesitter.configs").setup({
				highlight = { enable = true },
				incremental_selection = { enable = true },
				auto_install = true,
				ensure_installed = require("defaults").ensure_installed.treesitter,
			})
		end,
		dependencies = {
			{ "HiPhish/rainbow-delimiters.nvim", cond = group.plugins.rainbow },
			{ "JoosepAlviste/nvim-ts-context-commentstring" },
		},
	},
}
