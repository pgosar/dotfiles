return {
	"akinsho/toggleterm.nvim",
	cond = group.plugins.toggleterm,
  -- stylua: ignore
  keys = {
    {
      "<leader><C-\\>",
      "<CMD>ToggleTerm go_back=0 direction=float<CR>",
      desc = "Toggle floating terminal"
    },
    { "<C-\\>",     "<C-\\><C-n>",                                             mode = "t",              desc = "Toggle terminal when i" },
    { "<C-\\>",     "<CMD>ToggleTerm go_back=0<CR>",                           desc = "Toggle terminal" },
    { "<leader>tk", "<CMD>TermExec go_back=0 direction=float cmd='tokei'<CR>", desc = "Open tokei" },
    {
      "<leader>gg",
      function() require("core.utils.utils").create_floating_terminal("lazygit") end,
      desc = "open lazygit",
    },
  },
	opts = {
		size = 25,
		shade_terminals = false,
		start_in_insert = true,
		highlights = {
			Normal = {
				guibg = require("defaults").colors.terminal,
			},
		},
		direction = "horizontal",
		float_opts = { border = "curved" },
	},
}
