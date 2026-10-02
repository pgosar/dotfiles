-- luacheck: globals vim
-- Lua language server configuration for Lua and Neovim development
return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  settings = {
    Lua = {
      diagnostics = {
        disable = { "missing-fields" },
        globals = { "vim", "hl" },
      },
      hint = { enable = true },
      workspace = {
        -- Make language server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
}
