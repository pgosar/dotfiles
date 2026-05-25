-- Highlights and searches TODO, FIXME, HACK, and other special comments
return {
  "folke/todo-comments.nvim",
  cond = group.plugins.todo_comments,
  event = "VeryLazy",
  opts = {
    keywords = {
      FIX = { icon = icons.comments.fix },
      TODO = { icon = icons.comments.todo },
      HACK = { icon = icons.comments.hack },
      WARN = { icon = icons.comments.warn },
      PERF = { icon = icons.comments.perf },
      NOTE = { icon = icons.comments.note },
      TEST = { icon = icons.comments.test },
    },
  },
}
