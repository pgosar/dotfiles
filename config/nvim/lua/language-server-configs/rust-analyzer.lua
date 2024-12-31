return {
	settings = {
		["rust-analyzer"] = {
			inlayHints = { genericParameterHints = { lifetime = { enable = true } } },
			diagnostics = { styleLints = { enable = true } },
			checkOnSave = {
				allFeatures = true,
				command = "clippy",
			},
		},
	},
}
