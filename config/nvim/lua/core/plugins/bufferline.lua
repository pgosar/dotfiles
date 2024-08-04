return {
	"akinsho/bufferline.nvim",
	cond = group.plugins.bufferline,
	event = "VimEnter",
	keys = {
		{ "gb", "<CMD>BufferLinePick<CR>", desc = "pick buffer to open" },
	},
	config = function()
		require("bufferline").setup({
			highlights = {
				fill = { bg = require("defaults").colors.mocha_override.mantle },
			},
			options = {
				diagnostics = "nvim_lsp",
				separator_style = "thin",
				diagnostics_indicator = function(count, level)
					local icon = level:match("error") and icons.diagnostics.error or icons.diagnostics.warn
					return " " .. icon .. count
				end,
			},
		})
	end,
}
