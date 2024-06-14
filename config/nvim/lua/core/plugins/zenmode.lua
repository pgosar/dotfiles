return {
	"folke/zen-mode.nvim",
	cond = group.plugins.zen,
	cmd = "ZenMode",
	keys = {
		{ "<leader>zm", "<CMD>ZenMode<CR>", desc = "toggle zen mode" },
	},
	opts = {
		plugins = {
			options = {
				laststatus = 0,
			},
		},
	},
}
