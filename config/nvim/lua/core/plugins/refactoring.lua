return {
	"ThePrimeagen/refactoring.nvim",
	cond = group.plugins.refactoring,
	keys = {
		{
			"<leader>fr",
			function()
				require("telescope").extensions.refactoring.refactors()
			end,
			mode = { "n", "v" },
			desc = "Refactor in Telescope",
		},
	},
	config = function()
		require("refactoring").setup()
	end,
}
