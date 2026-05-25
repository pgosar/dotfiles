-- Smooth scrolling
return {
  "karb94/neoscroll.nvim",
  cond = group.plugins.neoscroll,
  event = "VeryLazy",
  opts = { easing = require("defaults").plugin_settings.neoscroll_easing, respect_scrolloff = true },
}

