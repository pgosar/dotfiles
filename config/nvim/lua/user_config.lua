local M = {}

-- Null-ls sources list
M.setup_sources = function(b)
	return {
		b.formatting.clang_format,
		b.completion.luasnip,
		b.completion.tags,
		b.formatting.stylua,
		b.formatting.cbfmt,
		b.formatting.shfmt,
		b.formatting.gofumpt,
		b.formatting.black,
		b.formatting.cmake_format,
		b.formatting.prettierd.with({
			filetypes = {
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
				"html",
				"css",
			},
		}),
		b.formatting.verible_verilog_format,
		b.diagnostics.verilator,
		b.diagnostics.checkmake,
		b.diagnostics.cmake_lint,
		b.diagnostics.pylint,
		b.diagnostics.revive,
		b.code_actions.gitrebase,
		b.code_actions.gitsigns,
		b.code_actions.gomodifytags,
		b.code_actions.refactoring,
		b.hover.dictionary,
	}
end

-- Auto install Mason sources
M.mason_ensure_installed = {
	null_ls = {
		"cbfmt",
		"clangd",
		"codelldb",
		"css_lsp",
		"debugpy",
		"delve",
		"gofumpt",
		"goimports_reviser",
		"gopls",
		"html_lsp",
		"jq",
		"json_lsp",
		"lua_language_server",
		"prettierd",
		"basedpyright",
		"rust_analyzer",
		"shfmt",
		"stylua",
		"svlangserver",
		"typescript_language_server",
		"verible",
		"wgsl_analyzer",
	},
	dap = {
		"python",
	},
}

-- setup formatting servers
M.formatting_servers = {
	["rust_analyzer"] = { "rust" },
	["null-ls"] = {
		"lua",
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"html",
		"css",
		"json",
		"python",
		"sh",
		"bash",
		"zsh",
		"go",
		"cpp",
		"c",
		"cmake",
		"systemverilog",
		"markdown",
	},
}

M.enable_plugins = {
	aerial = true,
	alpha = true,
	asyncrun = true,
	autotag = true,
	autosave = true,
	bufferline = true,
	catppuccin = true,
	copilot = true,
	dressing = true,
	gitsigns = true,
	hop = true,
	img_clip = true,
	indent_blankline = true,
	lsp_zero = true,
	lualine = true,
	neodev = true,
	neoscroll = true,
	neotree = true,
	session_manager = true,
	noice = true,
	null_ls = true,
	autopairs = true,
	cmp = true,
	colorizer = true,
	dap = true,
	dap_python = true,
	dropbar = true,
	notify = true,
	markdown = true,
	surround = true,
	treesitter = true,
	ufo = true,
	project = true,
	rainbow = true,
	rust_tools = true,
	scope = true,
	telescope = true,
	toggleterm = true,
	trouble = true,
	twilight = true,
	whichkey = true,
	zen = true,
}

M.autocommands = {
	alpha_folding = true,
	treesitter_folds = true,
	trailing_whitespace = true,
	remember_file_state = true,
	session_saved_notification = true,
	css_colorizer = true,
	cmp = true,
	trouble = true,
	term_spelling = true,
}

M.colorscheme = "catppuccin"

return M
