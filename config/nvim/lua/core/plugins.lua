local ok, defaults = pcall(require, "defaults")
if not ok then
	vim.api.nvim_err_writeln("Failed to load defaults.lua")
end
local group = defaults.group

require("lazy").setup({
	{
		"goolord/alpha-nvim",
		cond = group.plugins.alpha,
		lazy = false,
		config = function()
			require("plugin-configs.alpha")
		end,
	},
	{
		"skywind3000/asyncrun.vim",
		event = "VeryLazy",
		cond = group.plugins.asyncrun,
	},
	{
		"okuuva/auto-save.nvim",
		event = "VeryLazy",
		cond = group.plugins.autosave,
		config = function()
			require("plugin-configs.autosave")
		end,
	},
	{
		"akinsho/bufferline.nvim",
		cond = group.plugins.bufferline,
		event = "VeryLazy",
		config = function()
			require("plugin-configs.bufferline")
		end,
	},
	{
		"catppuccin/nvim",
		lazy = false,
		priority = 1000,
		cond = group.plugins.catppuccin,
		config = function()
			require("plugin-configs.catppuccin")
		end,
	},
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		cond = group.plugins.cmp and group.plugins.copilot,
		event = "InsertEnter",
		config = function()
			require("plugin-configs.copilot")
		end,
		dependencies = {
			"zbirenbaum/copilot-cmp",
			config = true,
		},
	},
	{
		"stevearc/dressing.nvim",
		cond = group.plugins.dressing,
		event = "VeryLazy",
		config = function()
			require("plugin-configs.dressing")
		end,
	},
	{
		"Bekaboo/dropbar.nvim",
		lazy = false, -- done by default
		cond = group.plugins.dropbar,
	},
	{
		"lewis6991/gitsigns.nvim",
		cond = group.plugins.gitsigns,
		event = "VeryLazy",
		config = function()
			require("plugin-configs.gitsigns")
		end,
	},
	{
		"smoka7/hop.nvim",
		cond = group.plugins.hop,
		event = "VeryLazy",
		config = function()
			require("plugin-configs.hop")
		end,
	},
	{
		"3rd/image.nvim",
		cond = group.plugins.image,
		dependencies = {
			{
				"vhyrro/luarocks.nvim",
				priority = 1001, -- this plugin needs to run before anything else
				opts = {
					rocks = { "magick" },
				},
			},
		},
		ft = "markdown",
		opts = {},
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		cond = group.plugins.indent_blankline,
		event = "VeryLazy",
		main = "ibl",
		config = true,
	},
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		cond = group.plugins.lualine,
		config = function()
			require("plugin-configs.lualine")
		end,
	},
	{
		"tadmccorkle/markdown.nvim",
		ft = "markdown",
		cond = group.plugins.markdown,
		opts = {},
	},
	{
		"MeanderingProgrammer/markdown.nvim",
		cond = group.plugins.markdown_render,
		name = "render-markdown",
		ft = "markdown",
		config = function()
			require("render-markdown").setup({})
		end,
	},
	{
		"echasnovski/mini.align",
		cond = group.plugins.align,
		event = "VeryLazy",
		config = true,
	},
	{
		"echasnovski/mini.move",
		cond = group.plugins.move,
		event = "VeryLazy",
		config = function()
			require("mini.move").setup()
		end,
	},
	-- TODO: blocked - https://github.com/brenton-leighton/multiple-cursors.nvim/issues/65
	{
		"brenton-leighton/multiple-cursors.nvim",
		cond = group.plugins.multicursor,
		opts = {}, -- This causes the plugin setup function to be called
		event = "VeryLazy",
	},
	{
		"jbyuki/nabla.nvim",
		cond = group.plugins.nabla,
		ft = { "markdown" },
	},
	{
		"folke/lazydev.nvim",
		cond = group.plugins.lazydev,
		ft = "lua",
		opts = {},
	},
	{
		"danymat/neogen",
		cond = group.plugins.neogen,
		event = "VeryLazy",
		config = function()
			require("plugin-configs.neogen")
		end,
	},
	{
		"nvim-neotest/neotest",
		cond = group.plugins.neotest,
		event = "VeryLazy",
		opts = {},
	},
	{
		"karb94/neoscroll.nvim",
		cond = group.plugins.neoscroll,
		event = "VeryLazy",
		config = function()
			require("plugin-configs.neoscroll")
		end,
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		cond = group.plugins.neotree,
		event = "VeryLazy",
		config = function()
			require("plugin-configs.neo-tree")
		end,
		branch = "v3.x",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
	{
		"folke/noice.nvim",
		cond = group.plugins.noice,
		event = "VeryLazy",
		config = function()
			require("plugin-configs.noice")
		end,
		dependencies = { { "MunifTanjim/nui.nvim" } },
	},
	{
		"nvimtools/none-ls.nvim",
		cond = group.plugins.null_ls,
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("plugin-configs.null-ls")
		end,
		dependencies = {
			{
				"jay-babu/mason-null-ls.nvim",
				cmd = { "NullLsInstall", "NullLsUninstall" },
				config = function()
					require("plugin-configs.mason-null-ls")
				end,
			},
		},
	},
	{
		"windwp/nvim-autopairs",
		cond = group.plugins.autopairs,
		event = "InsertEnter",
		config = function()
			require("plugin-configs.autopairs")
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		cond = group.plugins.cmp,
		event = { "InsertEnter", "CmdlineEnter" },
		config = function()
			require("plugin-configs.cmp")
		end,
		dependencies = {
			{ "onsails/lspkind.nvim" },
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-cmdline" },
			{ "hrsh7th/cmp-path" },
			{ "hrsh7th/cmp-nvim-lua" },
			{
				"garymjr/nvim-snippets",
				opts = { friendly_snippets = true },
				dependencies = { { "rafamadriz/friendly-snippets" } },
			},
		},
	},
	{
		"brenoprata10/nvim-highlight-colors",
		cond = group.plugins.highlight_colors,
		ft = { "css", "scss", "html", "xml", "svg", "js", "jsx", "ts", "tsx", "php", "vue" },
		opts = {},
	},
	{
		"mfussenegger/nvim-dap",
		cond = group.plugins.dap,
		event = "VeryLazy",
		config = function()
			require("plugin-configs.dap")
		end,
		dependencies = {
			{
				"mfussenegger/nvim-dap-python",
				ft = "python",
				cond = group.plugins.dap_python,
				config = function()
					require("plugin-configs.dap-python")
				end,
			},
			{
				"jay-babu/mason-nvim-dap.nvim",
				cmd = { "DapInstall", "DapUninstall" },
				config = function()
					require("plugin-configs.mason-nvim-dap")
				end,
			},
			{
				"rcarriga/nvim-dap-ui",
				config = true,
			},
			{
				"theHamsta/nvim-dap-virtual-text",
				config = true,
			},
			{
				"nvim-neotest/nvim-nio",
			},
		},
	},
	-- plugin order is important for these 3 -------------
	{
		"VonHeikemen/lsp-zero.nvim",
		cond = group.plugins.lsp_zero,
		event = { "BufReadPre", "BufNewFile" },
		branch = "v3.x",
		dependencies = {},
	},
	{
		"williamboman/mason.nvim",
		lazy = false,
		config = true,
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		cmd = { "LspInfo", "LspInstall", "LspStart" },
		config = function()
			require("plugin-configs.lsp")
		end,
		dependencies = {
			{ "williamboman/mason-lspconfig.nvim" },
		},
	},
	------------------------------------------------------
	{
		"rcarriga/nvim-notify",
		cond = group.plugins.notify,
		lazy = false,
		opts = {},
	},
	{
		"kylechui/nvim-surround",
		cond = group.plugins.surround,
		event = "VeryLazy",
		config = true,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		cond = group.plugins.treesitter,
		build = ":TSUpdate",
		lazy = false,
		config = function()
			require("plugin-configs.treesitter")
		end,
		dependencies = {
			{
				"echasnovski/mini.ai",
				config = function()
					require("mini.ai").setup()
				end,
			},
			{ "HiPhish/rainbow-delimiters.nvim", cond = group.plugins.rainbow },
			{ "JoosepAlviste/nvim-ts-context-commentstring" },
			{
				"windwp/nvim-ts-autotag",
				cond = group.plugins.autotag,
				event = { "BufReadPre", "BufNewFile" },
				config = true,
			},
		},
	},
	{
		"kevinhwang91/nvim-ufo",
		cond = group.plugins.ufo,
		event = "VeryLazy",
		dependencies = "kevinhwang91/promise-async",
		config = true,
	},
	{
		"epwalsh/obsidian.nvim",
		cond = group.plugins.obsidian,
		ft = "markdown",
		config = function()
			require("plugin-configs.obsidian")
		end,
	},
	{ "nvim-lua/plenary.nvim" },
	{
		"jedrzejboczar/possession.nvim",
		cond = group.plugins.possession,
		event = "VeryLazy",
		config = function()
			require("plugin-configs.possession")
		end,
	},

	{
		"ahmedkhalf/project.nvim",
		cond = group.plugins.project,
		event = "VeryLazy",
		config = function()
			require("project_nvim").setup()
		end,
	},
	{
		"ThePrimeagen/refactoring.nvim",
		cond = group.plugins.refactoring,
		event = "VeryLazy",
		config = function()
			require("refactoring").setup()
		end,
	},
	{
		"mrcjkb/rustaceanvim",
		cond = group.plugins.rustacean,
		version = "^4",
		lazy = false, -- This plugin is already lazy
	},
	{
		"tiagovla/scope.nvim",
		cond = group.plugins.scope,
		event = "VeryLazy",
		config = function()
			require("plugin-configs.scope")
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		cond = group.plugins.telescope,
		cmd = "Telescope",
		dependencies = {
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
			},
		},
		config = function()
			require("plugin-configs.telescope")
		end,
	},
	{
		"folke/todo-comments.nvim",
		cond = group.plugins.todo_comments,
		event = "VeryLazy",
		opts = {},
	},
	{
		"akinsho/toggleterm.nvim",
		cond = group.plugins.toggleterm,
		event = "VeryLazy",
		config = function()
			_G.term = require("plugin-configs.toggleterm")
		end,
	},
	{
		"folke/trouble.nvim",
		cond = group.plugins.trouble,
		cmd = "Trouble",
		config = function()
			require("plugin-configs.trouble")
		end,
	},
	{
		"jbyuki/venn.nvim",
		cond = group.plugins.venn,
		lazy = false,
	},
	{
		"RRethy/vim-illuminate",
		cond = group.plugins.illuminate,
		event = "VeryLazy",
		config = function()
			require("illuminate").configure()
		end,
	},
	{
		"folke/which-key.nvim",
		cond = group.plugins.whichkey,
		event = "VeryLazy",
		config = true,
	},
	{
		"artemave/workspace-diagnostics.nvim",
		cond = group.plugins.workspace_diagnostics,
		event = "VeryLazy",
	},
	{
		"folke/zen-mode.nvim",
		cond = group.plugins.zen,
		cmd = "ZenMode",
		config = function()
			require("plugin-configs.zenmode")
		end,
	},
	{
		"gregorias/nvim-mapper",
		config = function()
			require("nvim-mapper").setup({})
		end,
	},
}, {
	defaults = { lazy = true },
	performance = {
		rtp = {
			disabled_plugins = { "tohtml", "gzip", "zipPlugin", "netrwPlugin", "tarPlugin" },
		},
	},
})
