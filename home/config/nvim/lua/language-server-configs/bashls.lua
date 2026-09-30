-- Bash language server configuration
return {
  -- Explicit cmd: nvim-lspconfig defaults are not merging in this setup.
  cmd = { "bash-language-server", "start" },
  filetypes = { "sh", "bash", "zsh" },
}
