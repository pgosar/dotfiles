return {
  "petertriho/nvim-scrollbar",
  cond = group.plugins.scrollbar,
  event = "VeryLazy",
  opts = {
    handle = {
      color = require("defaults").colors.scrollbar,
    },
    handlers = {
      cursor = false,
      handle = true,
    },
  },
}

