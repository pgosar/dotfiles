-- Lua language server configuration for Lua and Neovim development
return {
  cmd = {"lua-language-server"},
  filetypes = {"lua"},
  settings = {
    Lua = {
      diagnostics = { disable = { "missing-fields" } },
      hint = { enable = true },
    },
  },
}
