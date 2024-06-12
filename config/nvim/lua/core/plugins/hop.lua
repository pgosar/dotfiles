return {
	"smoka7/hop.nvim",
	cond = group.plugins.hop,
	event = "VeryLazy",
	config = function()
		require("plugin-configs.hop")
	end,
}
