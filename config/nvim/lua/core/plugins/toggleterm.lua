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
		open_mapping = [[<c-t>]],
		on_open = function(_)
			vim.cmd("startinsert!")
		end,
		on_close = function(_)
			vim.cmd("startinsert!")
		end,
		size = 25,
		shade_terminals = false,
		direction = "horizontal",
		float_opts = {
			border = "curved",
			winblend = 6,
		},
	},
}
