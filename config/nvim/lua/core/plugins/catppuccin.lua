return {
	"catppuccin/nvim",
	lazy = false,
	priority = 1000,
	cond = group.plugins.catppuccin,
	config = function()
		require("plugin-configs.catppuccin")
	end,
}
