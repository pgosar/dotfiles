return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local _, lsp = pcall(require, "lsp-zero")

		lsp.set_sign_icons({
			error = "✘",
			warn = "▲",
			hint = "⚑",
			info = "»",
		})

		lsp.set_server_config({
			capabilities = {
				textDocument = {
					foldingRange = {
						dynamicRegistration = false,
						lineFoldingOnly = true,
					},
				},
				offsetEncoding = { "utf-16" },
			},
		})

		local ok, defaults = pcall(require, "defaults")
		if not ok then
			vim.api.nvim_err_writeln("Failed to load defaults.lua")
		end
		lsp.format_on_save({
			format_opts = {
				async = false,
				timeout_ms = 10000,
			},
			servers = defaults.formatting_servers,
		})

		local lspconfig = require("lspconfig")
		require("mason-lspconfig").setup()

		local default = {
			on_attach = function(client, bufnr)
				require("workspace-diagnostics").populate_workspace_diagnostics(client, bufnr)
			end,
		}

		require("mason-lspconfig").setup_handlers({
			function(server_name)
				lspconfig[server_name].setup(default)
			end,
		})

		-- Extend specific language server configurations
		local server_configs = {
			gopls = "language-server-configs.gopls",
			tsserver = "language-server-configs.tsserver",
			lua_ls = "language-server-configs.lua_ls",
			bashls = "language-server-configs.bashls",
		}

		for server, config_module in pairs(server_configs) do
			local ok, specific = pcall(require, config_module)
			if ok then
				lspconfig[server].setup(vim.tbl_deep_extend("force", {}, default, specific or {}))
			else
				vim.notify("Failed to load config for " .. server .. ": " .. specific)
				lspconfig[server].setup(default)
			end
		end
	end,
	dependencies = {
		{ "williamboman/mason-lspconfig.nvim" },
	},
}
