return {
	"tiagovla/scope.nvim",
	cond = group.plugins.scope,
	event = "VeryLazy",
	config = function()
		require("plugin-configs.scope")
	end,
}
