return {
	"rcarriga/nvim-notify",
	cond = group.plugins.notify,
	lazy = false,
	keys = {
		{
			"<ESC>",
			function()
				require("notify").dismiss({})
			end,
			desc = "Dismiss notifications",
		},
		{
			"<ESC>",
			function()
				require("notify").dismiss({})
				vim.cmd("stopinsert")
			end,
			mode = "i",
			desc = "Dismiss notifications",
		},
	},
	opts = {
		icons = {
			ERROR = icons.diagnostics.error,
			WARN = icons.diagnostics.warn,
			INFO = icons.diagnostics.info,
			DEBUG = icons.diagnostics.debug,
			TRACE = icons.diagnostics.trace,
		},
	},
}
