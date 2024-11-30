local M = {}

-- Null-ls sources list
M.setup_sources = function(b)
	return {
		b.formatting.clang_format,
		b.formatting.stylua,
		b.formatting.cbfmt,
		b.formatting.shfmt.with({
			filetypes = {
				"sh",
				"bash",
				"zsh",
			},
		}),
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
		b.code_actions.gitsigns,
		b.code_actions.gomodifytags,
		b.code_actions.refactoring,
	}
end

-- Auto install Mason sources
M.ensure_installed = {
	treesitter = {
		"asm",
		"bash",
		"c",
		"cmake",
		"comment",
		"cpp",
		"css",
		"csv",
		"cuda",
		"diff",
		"disassembly",
		"dockerfile",
		"xml",
		"gitattributes",
		"gitcommit",
		"gitignore",
		"glsl",
		"go",
		"gomod",
		"gosum",
		"html",
		"java",
		"javascript",
		"jsdoc",
		"json",
		"json5",
		"jsonc",
		"latex",
		"lua",
		"luap",
		"luau",
		"make",
		"markdown",
		"meson",
		"ninja",
		"objdump",
		"printf",
		"python",
		"regex",
		"ron",
		"rust",
		"scss",
		"toml",
		"tsx",
		"verilog",
		"wgsl",
		"yaml",
	},
	null_ls = {
		"rust_analyzer",
		"bash-language-server",
		"cbfmt",
		"clangd",
		"css-lsp",
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
		"shfmt",
		"stylua",
		"svlangserver",
		"typescript_language_server",
		"verible",
		"wgsl_analyzer",
	},
	dap = {
		"python",
		"codelldb",
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

-- default value is true for all
M.group = {
	plugins = {
		ai = true,
		align = true,
		alpha = true,
		asyncrun = true,
		autotag = true,
		autosave = true,
		bufferline = true,
		catppuccin = true,
		cmp = true,
		copilot = true,
		dap = true,
		dap_python = true,
		dressing = true,
		dropbar = true,
		gitsigns = true,
		highlight_colors = true,
		hop = true,
		illuminate = true,
		image = true,
		indent_blankline = true,
		lazydev = true,
		lsp_zero = true,
		lualine = true,
		markdown = true,
		markview = true,
		move = true,
		multicursor = true,
		neogen = true,
		neoscroll = true,
		neotest = true,
		neotree = true,
		noice = true,
		none_ls = true,
		notify = true,
		obsidian = true,
		possession = true,
		project = true,
		refactor = true,
		scrollbar = true,
		scope = true,
		surround = true,
		telescope = true,
		todo_comments = true,
		toggleterm = true,
		autopairs = true,
		rainbow = true,
		treesitter = true,
		trouble = true,
		ufo = true,
		venn = true,
		virt_column = true,
		whichkey = true,
		workspace_diagnostics = true,
		zen = true,
	},
	autocommands = {
		trailing_whitespace = true,
		remember_file_state = true,
		term_spelling = true,
		number = true,
		comment = true,
	},
}

M.colors = {
	mocha_override = {
		base = "#252525",
		mantle = "#272727",
		crust = "#252525",
	},
	scrollbar = "#2f334d",
}

M.colorscheme = "catppuccin"

_G.icons = {
	lualine = {
		lsp = " ",
	},
	comments = {
		fix = " ",
		todo = " ",
		hack = " ",
		warn = " ",
		perf = "󱑂 ",
		note = " ",
		test = "󰙨 ",
	},
	alpha = {
		new_file = " ",
		find = " ",
		recent = " ",
		last_session = " ",
		open_session = " ",
		open_project = " ",
	},
	cmp = {
		copilot = "",
	},
	dap = {
		breakpoint = " ",
		stopped = "󰁕 ",
	},
	diagnostics = {
		error = " ",
		warn = " ",
		hint = "󰌵",
		info = " ",
		debug = " ",
		trace = "✎",
	},
	git = {
		branch = "",
		added = " ",
		modified = " ",
		removed = " ",
		renamed = " ",
		untracked = "",
		ignored = " ",
		unstaged = "󰄱 ",
		staged = " ",
		conflict = "",
	},
	lsp = {
		error = "✘",
		warn = "▲",
		hint = "⚑",
		info = "»",
	},
}

M.lspkind_priority = {
	Parameter = 14,
	Variable = 12,
	Field = 11,
	Property = 11,
	Constant = 10,
	Enum = 10,
	EnumMember = 10,
	Event = 10,
	Function = 10,
	Method = 10,
	Operator = 10,
	Reference = 10,
	Struct = 10,
	File = 8,
	Folder = 8,
	Class = 5,
	Color = 5,
	Module = 5,
	Keyword = 2,
	Constructor = 1,
	Interface = 1,
	Snippet = 0,
	Text = 0,
	TypeParameter = 1,
	Unit = 1,
	Value = 1,
}

M.dashboard_ascii = [[		⠀⠀
           ⢀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀  ⠀⠀⠀⠀⠀⠀⠀⣴⣿⣿⠀⠀⠀⢠⣾⣧⣤⡖⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⠋⠀⠉⠀⢄⣸⣿⣿⣿⣿⣿⣥⡤⢶⣿⣦⣀⡀
⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⡆⠀⠀⠀⣙⣛⣿⣿⣿⣿⡏⠀⠀⣀⣿⣿⣿⡟
⠀⠀⠀⠀⠀⠀⠀⠀⠙⠻⠷⣦⣤⣤⣬⣽⣿⣿⣿⣿⣿⣿⣿⣟⠛⠿⠋⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⠋⣿⣿⣿⣿⣿⣿⣿⣿⢿⣿⣿⡆⠀⠀
⠀⠀⠀⠀⣠⣶⣶⣶⣿⣦⡀⠘⣿⣿⣿⣿⣿⣿⣿⣿⠿⠋⠈⢹⡏⠁⠀⠀
⠀⠀⠀⢀⣿⡏⠉⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡆⠀⢀⣿⡇⠀⠀⠀
⠀⠀⠀⢸⣿⠀⠀⠀⠀⠀⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣟⡘⣿⣿⣃⠀⠀⠀
⣴⣷⣀⣸⣿⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⠹⣿⣯⣤⣾⠏⠉⠉⠉⠙⠢⠀
⠈⠙⢿⣿⡟⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣄⠛⠉⢩⣷⣴⡆⠀⠀⠀⠀⠀
⠀⠀⠀⠋⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⣿⣀⡠⠋⠈⢿⣇⠀⠀
⠀⠀⠀          ⠙⠿⠿⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀
]]

return M
