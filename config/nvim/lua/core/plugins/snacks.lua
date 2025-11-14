return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		picker = { enabled = group.plugins.snacks_picker },
		zen = {
			enabled = true,
			win = {
				backdrop = { transparent = false },
				wo = { winbar = "" },
			},
			toggles = { dim = false },
			on_open = function() require("dropbar.menu").dropbar_menu_t:del() end,
		},
		bufdelete = {
			enabled = true,
		},
	},
	keys = {
		{
			"<leader>zm",
			function() Snacks.zen() end,
			desc = "Toggle Zen Mode",
		},
	},
}
