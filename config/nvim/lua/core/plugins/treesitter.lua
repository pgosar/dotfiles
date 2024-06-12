return {
	"nvim-treesitter/nvim-treesitter",
	cond = group.plugins.treesitter,
	build = ":TSUpdate",
	lazy = false,
	config = function()
		require("plugin-configs.treesitter")
	end,
	dependencies = {
		{
			"echasnovski/mini.ai",
			config = function()
				require("mini.ai").setup()
			end,
		},
		{ "HiPhish/rainbow-delimiters.nvim", cond = group.plugins.rainbow },
		{ "JoosepAlviste/nvim-ts-context-commentstring" },
		{
			"windwp/nvim-ts-autotag",
			cond = group.plugins.autotag,
			event = { "BufReadPre", "BufNewFile" },
			config = true,
		},
	},
}
