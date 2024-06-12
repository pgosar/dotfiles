return {
	"ThePrimeagen/refactoring.nvim",
	cond = group.plugins.refactoring,
	event = "VeryLazy",
	config = function()
		require("refactoring").setup()
	end,
}
