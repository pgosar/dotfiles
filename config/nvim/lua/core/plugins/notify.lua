return {
	"rcarriga/nvim-notify",
	cond = group.plugins.notify,
	lazy = false,
	keys = {
		{
			"<ESC>",
			function()
				---@diagnostic disable-next-line: missing-fields
				require("notify").dismiss({})
			end,
			mode = "n",
			desc = "Dismiss notifications",
		},
		{
			"<ESC>",
			function()
				---@diagnostic disable-next-line: missing-fields
				require("notify").dismiss({})
				vim.cmd("stopinsert")
			end,
			mode = "i",
			desc = "Dismiss notifications",
		},
	},
	opts = {},
}
