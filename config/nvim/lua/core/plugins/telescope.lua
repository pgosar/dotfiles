return {
	"nvim-telescope/telescope.nvim",
	cond = group.plugins.telescope,
	cmd = "Telescope",
	keys = {
		{ "<leader>ff", "<CMD>Telescope find_files hidden=true<CR>", mode = "n", desc = "Find files in Telescope" },
		{ "<leader>fg", "<CMD>Telescope live_grep<CR>", mode = "n", desc = "Grep in Telescope" },
		{ "<leader>fb", "<CMD>Telescope buffers<CR>", mode = "n", desc = "Search available buffers in Telescope" },
		{ "<leader>fp", "<CMD>Telescope projects<CR>", mode = "n", desc = "Search available projects in Telescope" },
	},
	config = function()
		local telescope = require("telescope")
		telescope.load_extension("scope")
		telescope.load_extension("notify")
		telescope.load_extension("noice")
		telescope.load_extension("projects")
		telescope.load_extension("possession")
		telescope.load_extension("refactoring")
	end,
	dependencies = {
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
		},
		{ "nvim-lua/plenary.nvim" },
	},
}
