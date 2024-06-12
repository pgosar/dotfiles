return {
	"jedrzejboczar/possession.nvim",
	cond = group.plugins.possession,
	event = "VeryLazy",
	config = function()
		require("plugin-configs.possession")
	end,
}
