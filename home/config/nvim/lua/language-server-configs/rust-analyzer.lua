-- Rust-analyzer LSP configuration for Rust
return {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  settings = {
    ["rust-analyzer"] = {
      inlayHints = { genericParameterHints = { lifetime = { enable = true } } },
      diagnostics = { styleLints = { enable = true } },
      checkOnSave = true,
      check = {
        allFeatures = true,
        command = "clippy",
      },
    },
  },
}
