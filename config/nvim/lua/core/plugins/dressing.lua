return {
	"stevearc/dressing.nvim",
	cond = group.plugins.dressing,
	event = "VeryLazy",
	config = function()
		require("plugin-configs.dressing")
	end,
}
