return {
	"okuuva/auto-save.nvim",
	event = "VeryLazy",
	cond = group.plugins.autosave,
	config = function()
		require("plugin-configs.autosave")
	end,
}
