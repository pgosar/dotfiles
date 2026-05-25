-- LSP diagnostics for all files in the workspace
return {
  "artemave/workspace-diagnostics.nvim",
  cond = group.plugins.workspace_diagnostics,
  event = "VeryLazy",
}
