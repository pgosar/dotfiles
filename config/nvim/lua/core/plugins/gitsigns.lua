return {
	"lewis6991/gitsigns.nvim",
	cond = group.plugins.gitsigns,
	event = "VeryLazy",
	config = function()
		require("plugin-configs.gitsigns")
	end,
}
