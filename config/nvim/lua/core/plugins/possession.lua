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
			tmp = true,
			tmp_name = "tmp",
			on_load = true,
			on_quit = true,
		},
		hooks = {
			after_save = function()
				vim.cmd([[ScopeSaveState]])
			end,
			after_load = function()
				vim.cmd([[ScopeLoadState]])
			end,
		},
	},
}
