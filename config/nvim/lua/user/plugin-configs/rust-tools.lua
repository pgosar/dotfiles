HOME_PATH = os.getenv("HOME") .. "/"
MASON_PATH = HOME_PATH .. ".local/share/nvim/mason/packages/"
local codelldb_path = MASON_PATH .. "codelldb/extension/adapter/codelldb"
local liblldb_path = MASON_PATH .. "codelldb/extension/lldb/lib/liblldb.so"

local rust_ok, rt = pcall(require, "rust-tools")
if rust_ok then
	rt.setup({
		server = {
			on_attach = function(_, bufnr)
				vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
			end,
		},
		dap = {
			adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
		},
	})
end
