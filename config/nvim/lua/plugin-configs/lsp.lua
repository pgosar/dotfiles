local lsp_ok, lsp = pcall(require, "lsp-zero")
if not lsp_ok then
	return
end

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

local exist, user_config = pcall(require, "user_config")
local formatting_servers = exist and type(user_config) == "table" and user_config.formatting_servers or {}
lsp.format_on_save({
	format_opts = {
		async = false,
		timeout_ms = 10000,
	},
	servers = formatting_servers,
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
