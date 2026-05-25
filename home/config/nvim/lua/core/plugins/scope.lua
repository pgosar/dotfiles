-- Makes each tab have its own set of buffers
return {
  "tiagovla/scope.nvim",
  cond = group.plugins.scope,
  event = "VeryLazy",
  opts = {
    restore_state = true,
  },
}
