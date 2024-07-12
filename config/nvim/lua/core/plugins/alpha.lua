return {
	"goolord/alpha-nvim",
	cond = group.plugins.alpha,
	event = "VimEnter",
	config = function()
		local dashboard = require("alpha.themes.dashboard")
		dashboard.section.header.val = vim.split(require("defaults").dashboard_ascii, "\n")
		dashboard.section.buttons.val = {
			dashboard.button("e", icons.alpha.new_file .. "  New file", function()
				require("core.utils.utils").create_new_file()
			end),
			dashboard.button("f", icons.alpha.find .. "  Find file in git repo", ":Telescope git_files <CR>"),
			dashboard.button("r", icons.alpha.recent .. "  Recent", ":Telescope oldfiles<CR>"),
			dashboard.button("l", icons.alpha.last_session .. "  Open last session", ":PossessionLoad<CR>"),
			dashboard.button("o", icons.alpha.open_session .. "  Open session", ":Telescope possession list<CR>"),
			dashboard.button("p", icons.alpha.open_project .. "  Open project", ":Telescope projects<CR>"),
		}
		local fortune = require("alpha.fortune")
		dashboard.section.footer.val = fortune()

		require("alpha").setup(dashboard.opts)
	end,
}
