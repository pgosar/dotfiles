return {
	"stevearc/dressing.nvim",
	cond = group.plugins.dressing,
	event = "VeryLazy",
	opts = {
		input = {
			title_pos = "center",
			insert_only = false,
		},
		mappings = false,
	},
}