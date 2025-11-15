return {
  "folke/persistence.nvim",
  cond = group.plugins.persistence,
  event = "BufReadPre",
  keys = {
    {
      "<leader>qL",
      function() require("persistence").load() end,
      desc = "Load current directory's session",
    },
    {
      "<leader>qs",
      function() require("persistence").select() end,
      desc = "Select session to load",
    },
    {
      "<leader>ql",
      function() require("persistence").load({ last = true }) end,
      desc = "Load last session",
    },
    {
      "<leader>qd",
      function() require("persistence").stop() end,
      desc = "don't save session",
    },
  },
  opts = {},
}
