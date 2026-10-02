-- BasedPyright LSP configuration for Python
return {
  cmd = {"basedpyright-langserver", "--stdio"},
  filetypes = {"python"},
  settings = {
    basedpyright = {
      analysis = {
        autoFormatStrings = true,
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
  },
}
