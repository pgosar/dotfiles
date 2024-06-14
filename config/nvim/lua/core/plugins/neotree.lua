return {
	"nvim-neo-tree/neo-tree.nvim",
	cond = group.plugins.neotree,
	cmd = "Neotree",
	keys = {
		{ "<leader>nt", "<CMD>Neotree float reveal toggle<CR>", desc = "toggle neotree" },
	},
	opts = {
		close_if_last_window = true,
		window = {
			mappings = {
				["C"] = "close_all_subnodes",
				["Z"] = "expand_all_nodes",
			},
		},
		filesystem = {
			follow_current_file = {
				enabled = true,
			},
			window = {
				mappings = {
					["/"] = "filter_on_submit",
				},
			},
			hijack_netrw_behavior = "open_current",
		},
	},
	init = function()
		local stats = vim.uv.fs_stat(vim.fn.argv(0))
		if stats and stats.type == "directory" then
			require("neo-tree")
		end
	end,
	branch = "v3.x",
	dependencies = { "nvim-tree/nvim-web-devicons" },
}
