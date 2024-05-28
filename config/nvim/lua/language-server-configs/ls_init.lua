local enabled = require("core.utils.utils").enabled
local exist, user_config = pcall(require, "user_config")
local group = exist and type(user_config) == "table" and user_config.enable_plugins or {}

if enabled(group, "lsp_zero") then
	for _, source in ipairs({
		"language-server-configs.lua",
		"language-server-configs.tsserver",
		"language-server-configs.gopls",
	}) do
		local status_ok, fault = pcall(require, source)
		if not status_ok then
			vim.notify("Failed to load " .. source .. "\n\n" .. fault, "error")
		end
	end
end
