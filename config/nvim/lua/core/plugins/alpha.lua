return {
	"goolord/alpha-nvim",
	cond = group.plugins.alpha,
	lazy = false,
	config = function()
		require("plugin-configs.alpha")
	end,
}
