-- Lua language server configuration for Lua and Neovim development
return {
  settings = {
    Lua = {
      diagnostics = { disable = { "missing-fields" } },
      hint = { enable = true },
    },
  },
}
