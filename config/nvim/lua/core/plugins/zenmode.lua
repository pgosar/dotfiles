return {
	"folke/zen-mode.nvim",
	cond = group.plugins.zen,
	cmd = "ZenMode",
	keys = {
		{ "<leader>zm", "<CMD>ZenMode<CR>", desc = "toggle zen mode" },
	},
	opts = {
		window = {
			options = {
				signcolumn = "no",
			},
		},
		plugins = {
			options = {
				laststatus = 0,
			},
		},
		on_open = function()
			require("dropbar.menu").dropbar_menu_t:del()
		end,
	},
}
