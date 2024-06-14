return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = "InsertEnter",
	cond = group.plugins.cmp and group.plugins.copilot,
	opts = {
		suggestion = {
			auto_trigger = true,
			enabled = false,
		},
		panel = {
			enabled = false,
		},
	},
	dependencies = {
		"zbirenbaum/copilot-cmp",
		config = true,
	},
}
