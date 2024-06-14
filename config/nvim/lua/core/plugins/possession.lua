return {
	"jedrzejboczar/possession.nvim",
	cond = group.plugins.possession,
	cmd = {
		"PossessionSave",
		"PossessionLoad",
		"PossessionList",
		"PossessionShow",
		"PossessionRename",
		"PossessionClose",
		"PossessionDelete",
	},
	opts = {
		autosave = {
			current = true,
			tmp = false,
			tmp_name = "tmp",
			on_load = true,
			on_quit = true,
		},
	},
}
