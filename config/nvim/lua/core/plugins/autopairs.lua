return {
	"windwp/nvim-autopairs",
	cond = group.plugins.autopairs,
	event = "InsertEnter",
	config = function()
		require("plugin-configs.autopairs")
	end,
}
