return {
	"karb94/neoscroll.nvim",
	cond = group.plugins.neoscroll,
	event = "VeryLazy",
	config = function()
		require("plugin-configs.neoscroll")
	end,
}
