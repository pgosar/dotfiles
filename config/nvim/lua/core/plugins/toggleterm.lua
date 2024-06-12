return {
	"akinsho/toggleterm.nvim",
	cond = group.plugins.toggleterm,
	event = "VeryLazy",
	config = function()
		_G.term = require("plugin-configs.toggleterm")
	end,
}
