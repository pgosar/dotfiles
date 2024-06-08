local enabled = require("core.utils.utils").enabled
local plugin_group = require("core.utils.utils").plugin_group
require("lazy").setup({
	{
		"goolord/alpha-nvim",
		cond = enabled(plugin_group, "alpha"),
		lazy = false,
		config = function()
			require("plugin-configs.alpha")
		end,
	},
	{
		"skywind3000/asyncrun.vim",
		event = "VeryLazy",
		cond = enabled(plugin_group, "asyncrun"),
	},
	{
		"okuuva/auto-save.nvim",
		event = "VeryLazy",
		cond = enabled(plugin_group, "autosave"),
		config = function()
			require("plugin-configs.autosave")
		end,
	},
	{
		"akinsho/bufferline.nvim",
		cond = enabled(plugin_group, "bufferline"),
		lazy = false,
		config = function()
			require("plugin-configs.bufferline")
		end,
	},
	{
		"catppuccin/nvim",
		lazy = false,
		priority = 1000,
		cond = enabled(plugin_group, "catppuccin"),
		config = function()
			require("plugin-configs.catppuccin")
		end,
	},
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		cond = enabled(plugin_group, "cmp") and enabled(plugin_group, "copilot"),
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
		cond = enabled(plugin_group, "dressing"),
		event = "VeryLazy",
		config = function()
			require("plugin-configs.dressing")
		end,
	},
	{
		"Bekaboo/dropbar.nvim",
		lazy = false, -- done by default
		cond = enabled(plugin_group, "dropbar"),
	},
	{
		"lewis6991/gitsigns.nvim",
		cond = enabled(plugin_group, "gitsigns"),
		event = "VeryLazy",
		config = function()
			require("plugin-configs.gitsigns")
		end,
	},
	{
		"smoka7/hop.nvim",
		cond = enabled(plugin_group, "hop"),
		event = "VeryLazy",
		config = function()
			require("plugin-configs.hop")
		end,
	},
	{
		"3rd/image.nvim",
		cond = enabled(plugin_group, "image"),
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
		cond = enabled(plugin_group, "indent_blankline"),
		event = "VeryLazy",
		main = "ibl",
		config = true,
	},
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		cond = enabled(plugin_group, "lualine"),
		config = function()
			require("plugin-configs.lualine")
		end,
	},
	{
		"tadmccorkle/markdown.nvim",
		ft = "markdown",
		cond = enabled(plugin_group, "markdown"),
		opts = {},
	},
	{
		"MeanderingProgrammer/markdown.nvim",
		cond = enabled(plugin_group, "markdown_render"),
		name = "render-markdown",
		ft = "markdown",
		config = function()
			require("render-markdown").setup({})
		end,
	},
	{
		"echasnovski/mini.align",
		cond = enabled(plugin_group, "align"),
		event = "VeryLazy",
		config = true,
	},
	{
		"echasnovski/mini.move",
		cond = enabled(plugin_group, "move"),
		event = "VeryLazy",
		config = function()
			require("mini.move").setup()
		end,
	},
	-- TODO: blocked - https://github.com/brenton-leighton/multiple-cursors.nvim/issues/65
	{
		"brenton-leighton/multiple-cursors.nvim",
		opts = {}, -- This causes the plugin setup function to be called
		event = "VeryLazy",
	},
	{
		"jbyuki/nabla.nvim",
		cond = enabled(plugin_group, "nabla"),
		ft = { "markdown" },
	},
	{
		"folke/lazydev.nvim",
		cond = enabled(plugin_group, "align"),
		ft = "lua",
		opts = {},
	},
	{
		"danymat/neogen",
		cond = enabled(plugin_group, "neogen"),
		event = "VeryLazy",
		config = function()
			require("plugin-configs.neogen")
		end,
	},
	{ "nvim-neotest/neotest", cond = enabled(plugin_group, "neotest"), event = "VeryLazy", opts = {} },
	{
		"karb94/neoscroll.nvim",
		cond = enabled(plugin_group, "neoscroll"),
		event = "VeryLazy",
		config = function()
			require("plugin-configs.neoscroll")
		end,
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		cond = enabled(plugin_group, "neotree"),
		event = "VeryLazy",
		config = function()
			require("plugin-configs.neo-tree")
		end,
		branch = "v3.x",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
	{
		"folke/noice.nvim",
		cond = enabled(plugin_group, "noice"),
		event = "VeryLazy",
		config = function()
			require("plugin-configs.noice")
		end,
		dependencies = { { "MunifTanjim/nui.nvim" } },
	},
	{
		"nvimtools/none-ls.nvim",
		cond = enabled(plugin_group, "null_ls"),
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
		cond = enabled(plugin_group, "autopairs"),
		event = "InsertEnter",
		config = function()
			require("plugin-configs.autopairs")
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		cond = enabled(plugin_group, "cmp"),
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
		cond = enabled(plugin_group, "colorizer"),
		ft = { "css", "scss", "html", "xml", "svg", "js", "jsx", "ts", "tsx", "php", "vue" },
		opts = {},
	},
	{
		"mfussenegger/nvim-dap",
		cond = enabled(plugin_group, "dap"),
		event = "VeryLazy",
		config = function()
			require("plugin-configs.dap")
		end,
		dependencies = {
			{
				"mfussenegger/nvim-dap-python",
				ft = "python",
				cond = enabled(plugin_group, "dap_python") and enabled(plugin_group, "dap"),
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
		cond = enabled(plugin_group, "lsp_zero"),
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
		cond = enabled(plugin_group, "notify"),
		lazy = false,
		opts = {},
	},
	{
		"kylechui/nvim-surround",
		cond = enabled(plugin_group, "surround"),
		event = "VeryLazy",
		config = true,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		cond = enabled(plugin_group, "treesitter"),
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
			{ "HiPhish/rainbow-delimiters.nvim", cond = enabled(plugin_group, "rainbow") },
			{ "JoosepAlviste/nvim-ts-context-commentstring" },
			{
				"windwp/nvim-ts-autotag",
				cond = enabled(plugin_group, "autotag"),
				event = { "BufReadPre", "BufNewFile" },
				config = true,
			},
		},
	},
	{
		"kevinhwang91/nvim-ufo",
		cond = enabled(plugin_group, "ufo"),
		event = "VeryLazy",
		dependencies = "kevinhwang91/promise-async",
		config = true,
	},
	{
		"epwalsh/obsidian.nvim",
		cond = enabled(plugin_group, "obsidian"),
		ft = "markdown",
		config = function()
			require("plugin-configs.obsidian")
		end,
	},
	{ "nvim-lua/plenary.nvim" },
	{
		"jedrzejboczar/possession.nvim",
		cond = enabled(plugin_group, "possession"),
		event = "VeryLazy",
		config = function()
			require("plugin-configs.possession")
		end,
	},

	{
		"ahmedkhalf/project.nvim",
		cond = enabled(plugin_group, "project"),
		event = "VeryLazy",
		config = function()
			require("project_nvim").setup()
		end,
	},
	{
		"ThePrimeagen/refactoring.nvim",
		cond = enabled(plugin_group, "refactoring"),
		event = "VeryLazy",
		config = function()
			require("refactoring").setup()
		end,
	},
	{
		"mrcjkb/rustaceanvim",
		cond = enabled(plugin_group, "rustacean"),
		version = "^4",
		lazy = false, -- This plugin is already lazy
	},
	{
		"tiagovla/scope.nvim",
		cond = enabled(plugin_group, "scope"),
		event = "VeryLazy",
		config = function()
			require("plugin-configs.scope")
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		cond = enabled(plugin_group, "telescope"),
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
		cond = enabled(plugin_group, "todo_comments"),
		event = "VeryLazy",
		opts = {},
	},
	{
		"akinsho/toggleterm.nvim",
		cond = enabled(plugin_group, "toggleterm"),
		event = "VeryLazy",
		config = function()
			_G.term = require("plugin-configs.toggleterm")
		end,
	},
	{
		"folke/trouble.nvim",
		cond = enabled(plugin_group, "trouble"),
		cmd = "Trouble",
		config = function()
			require("plugin-configs.trouble")
		end,
	},
	{
		"RRethy/vim-illuminate",
		cond = enabled(plugin_group, "illuminate"),
		event = "VeryLazy",
		config = function()
			require("illuminate").configure()
		end,
	},
	{
		"folke/which-key.nvim",
		cond = enabled(plugin_group, "whichkey"),
		event = "VeryLazy",
		config = true,
	},
	{
		"folke/zen-mode.nvim",
		cond = enabled(plugin_group, "zen"),
		cmd = "ZenMode",
		config = function()
			require("plugin-configs.zenmode")
		end,
	},
	{ "artemave/workspace-diagnostics.nvim", cond = enabled(plugin_group, "workspace_diagnostics"), lazy = false },
}, {
	defaults = { lazy = true },
	performance = {
		rtp = {
			disabled_plugins = { "tohtml", "gzip", "zipPlugin", "netrwPlugin", "tarPlugin" },
		},
	},
})
