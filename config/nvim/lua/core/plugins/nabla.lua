return {
	"jbyuki/nabla.nvim",
	cond = group.plugins.nabla,
	init = function()
		vim.api.nvim_create_autocmd("BufEnter", {
			pattern = "*.md",
			callback = function()
				if vim.bo.filetype == "markdown" then
					require("core.utils.utils").map("n", "K", function()
						require("nabla").popup()
					end, { buffer = true, desc = "toggle nabla latex viewer popup" })
				end
			end,
		})
	end,
	ft = { "markdown" },
}
