return {
	"jbyuki/nabla.nvim",
	cond = group.plugins.nabla,
	init = function()
		vim.api.nvim_create_autocmd("BufEnter", {
			pattern = "*.md",
			callback = function()
				if vim.bo.filetype == "markdown" then
					require("nabla").enable_virt({
						autogen = true,
						silent = true,
					})
				end
			end,
		})
	end,
	ft = { "markdown" },
}
