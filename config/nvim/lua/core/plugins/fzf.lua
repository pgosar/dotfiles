return {
	"ibhagwan/fzf-lua",
	cmd = "FzfLua",
	cond = group.plugins.fzf,
	keys = {
		{
			"<leader>ff",
			function()
				require("fzf-lua").files()
			end,
			desc = "Find files",
		},
		{
			"<leader>fg",
			function()
				require("fzf-lua").live_grep()
			end,
			desc = "Grep for text",
		},
		{
			"<leader>fb",
			function()
				require("fzf-lua").buffers()
			end,
			desc = "Search through open buffers",
		},
	},
	opts = {},
}
