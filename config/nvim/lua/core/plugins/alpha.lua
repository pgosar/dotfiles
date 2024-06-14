return {
	"goolord/alpha-nvim",
	cond = group.plugins.alpha,
	event = "VimEnter",
	config = function()
		local dashboard = require("alpha.themes.dashboard")
		dashboard.section.header.val = {
			" ██████╗██╗   ██╗██████╗ ███████╗██████╗ ███╗   ██╗██╗   ██╗██╗███╗   ███╗",
			"██╔════╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗████╗  ██║██║   ██║██║████╗ ████║",
			"██║      ╚████╔╝ ██████╔╝█████╗  ██████╔╝██╔██╗ ██║██║   ██║██║██╔████╔██║",
			"██║       ╚██╔╝  ██╔══██╗██╔══╝  ██╔══██╗██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
			"╚██████╗   ██║   ██████╔╝███████╗██║  ██║██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
			" ╚═════╝   ╚═╝   ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
		}
		dashboard.section.buttons.val = {
			dashboard.button("e", "  > New file", ":lua require('core.utils.utils').create_new_file()<CR>"),
			dashboard.button("f", "  > Find file in git repo", ":Telescope git_files <CR>"),
			dashboard.button("r", "  > Recent", ":Telescope oldfiles<CR>"),
			dashboard.button("l", "🗘  > Open last session", ":PossessionLoad<CR>"),
			dashboard.button("o", "  > Open session", ":Telescope possession list<CR>"),
			dashboard.button("p", "  > Open project", ":Telescope projects<CR>"),
		}
		local fortune = require("alpha.fortune")
		dashboard.section.footer.val = fortune()

		require("alpha").setup(dashboard.opts)
	end,
}
