return {
	"goolord/alpha-nvim",
	cond = group.plugin.alpha,
	event = "VimEnter",
	config = function()
		local dashboard = require("alpha.themes.dashboard")
		dashboard.section.header.val = vim.split(require("defaults").dashboard_ascii, "\n")
		---@diagnostic disable: param-type-mismatch
		dashboard.section.buttons.val = {
			dashboard.button("e", icons.alpha.new_file .. "  New file", function()
				require("core.utils.utils").create_new_file()
			end),
			dashboard.button("f", icons.alpha.find .. "  Find file", ":FzfLua files<CR>"),
			dashboard.button("r", icons.alpha.recent .. "  Recent", ":FzfLua oldfiles<CR>"),
			dashboard.button("l", icons.alpha.last_session .. "  Open last session", function()
				require("persistence").load({ last = true })
			end),
			dashboard.button("o", icons.alpha.open_session .. "  Open session", function()
				require("persistence").select()
			end),
		}
		local fortune = require("alpha.fortune")
		dashboard.section.footer.val = fortune()

		require("alpha").setup(dashboard.opts)
	end,
}
