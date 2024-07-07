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
		plugins = { delete_hidden_buffers = false, delete_buffers = true, dapui = false },
		autosave = {
			current = true,
			cwd = true,
			tmp = true,
			tmp_name = "last",
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
