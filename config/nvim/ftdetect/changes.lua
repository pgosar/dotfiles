vim.filetype.add({
	extension = {
		wgsl = "wgsl",
	},
	pattern = {
		["%.env.*"] = "sh",
	},
})
