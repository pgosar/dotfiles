return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	cond = group.plugins.cmp and group.plugins.copilot,
	event = "InsertEnter",
	config = function()
		require("plugin-configs.copilot")
	end,
	dependencies = {
		"zbirenbaum/copilot-cmp",
		config = true,
	},
}
