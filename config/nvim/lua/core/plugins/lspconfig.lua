return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lsp_ok, lsp = pcall(require, "lsp-zero")
		local _, defaults = pcall(require, "defaults")
		if lsp_ok then
			lsp.set_sign_icons({
				error = icons.lsp.error,
				warn = icons.lsp.warn,
				hint = icons.lsp.hint,
				info = icons.lsp.info,
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
			lsp.format_on_save({
				format_opts = {
					async = false,
					timeout_ms = 10000,
				},
				servers = defaults.formatting_servers,
			})
		end

		local lspconfig = require("lspconfig")
		require("mason-lspconfig").setup()

		local default = {
			on_attach = function(client, bufnr)
				local wd_ok, wd = pcall(require, "workspace-diagnostics")
				if wd_ok then
					wd.populate_workspace_diagnostics(client, bufnr)
					-- HACK: For some reason the above method call causes lualine's diff view to break,
					-- and it only works again after re-entering the buffer which the below simulates
					vim.cmd([[silent! doautocmd BufLeave]])
					vim.cmd([[silent! doautocmd BufEnter]])
				end
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
			local spec_ok, specific = pcall(require, config_module)
			if spec_ok then
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
