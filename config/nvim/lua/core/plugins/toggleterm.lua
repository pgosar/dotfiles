return {
	"akinsho/toggleterm.nvim",
	cond = group.plugins.toggleterm,
	keys = {
		{ "<C-\\>", "<C-\\><C-n>", mode = "t", desc = "Toggle terminal when in terminal" },
		{ "<C-\\>", "<CMD>ToggleTerm go_back=0<CR>", mode = "n", desc = "Toggle terminal" },
		{ "<leader>tk", "<CMD>TermExec go_back=0 direction=float cmd='tokei'<CR>", mode = "n", desc = "Open tokei" },
		{
			"<leader>gg",
			function()
				require("core.utils.utils").create_floating_terminal("lazygit")
			end,
			desc = "open lazygit",
		},
	},
	opts = {
		size = 25,
		shade_terminals = false,
		direction = "horizontal",
		float_opts = {
			border = "curved",
		},
	},
}
