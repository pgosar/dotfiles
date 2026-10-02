-- Clangd LSP configuration for C/C++
return {
  cmd = {"clangd"},
  filetypes = {"c", "cpp", "objc", "objcpp", "cuda", "proto"},
  capabilities = { offsetEncoding = { "utf-16" } },
}
