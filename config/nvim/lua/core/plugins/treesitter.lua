return {
	{
		"nvim-treesitter/nvim-treesitter",
		cond = group.plugins.treesitter,
		build = ":TSUpdate",
		lazy = false,
		opts = {
			highlight = {
				enable = true,
			},
			incremental_selection = { enable = true },
			auto_install = true,
		},
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = require("defaults").ensure_installed.treesitter,
			})
		end,
		dependencies = {
			{ "HiPhish/rainbow-delimiters.nvim", cond = group.plugins.rainbow },
			{ "JoosepAlviste/nvim-ts-context-commentstring" },
		},
	},
	{
		"windwp/nvim-ts-autotag",
		cond = group.plugins.autotag,
		ft = {
			"html",
			"xml",
			"javascript",
			"typescript",
			"typescriptreact",
			"javascriptreact",
			"svelte",
			"vue",
			"markdown",
		},
		config = true,
	},
}
