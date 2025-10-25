return {
	settings = {
		["rust-analyzer"] = {
			inlayHints = { genericParameterHints = { lifetime = { enable = true } } },
			diagnostics = { styleLints = { enable = true } },
			checkOnSave = true,
			check = {
				allFeatures = true,
				command = "clippy",
			},
		},
	},
}
