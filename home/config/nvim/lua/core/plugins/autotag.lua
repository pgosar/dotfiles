-- Rename closing HTML/JSX tags when you change the opening tag
return {
  "windwp/nvim-ts-autotag",
  cond = group.plugins.autotag,
  ft = {
    "html",
    "xml",
    "javascript",
    "typescript",
    "typescriptreact",
    "javascriptreact",
    "svelte",
    "vue",
    "markdown",
  },
  opts = {},
}
