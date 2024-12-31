return {
	"ibhagwan/fzf-lua",
	cmd = "FzfLua",
	cond = group.plugins.fzf,
	keys = {
		{ "<leader>ff", "<CMD>FzfLua files<CR>", desc = "Find files" },
		{ "<leader>fg", "<CMD>FzfLua live_grep<CR>", "Grep for text" },
		{ "<leader>fb", "<CMD>FzfLua buffers<CR>", "Search through open buffers" },
	},
	opts = {},
}