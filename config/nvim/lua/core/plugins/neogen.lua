return {
	"danymat/neogen",
	cond = group.plugins.neogen,
	event = "VeryLazy",
	config = function()
		require("plugin-configs.neogen")
	end,
}
