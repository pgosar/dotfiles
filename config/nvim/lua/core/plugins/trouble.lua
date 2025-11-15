return {
  "folke/trouble.nvim",
  cond = group.plugins.trouble,
  keys = {
    {
      "<leader>tf",
      function() require("trouble").toggle("diagnostics") end,
      desc = "Trouble toggle diagnostics",
    },
    {
      "<leader>tt",
      function() require("trouble").toggle("todo") end,
      desc = "Trouble toggle todo",
    },
    {
      "<leader>ts",
      function() require("trouble").toggle("symbols") end,
      desc = "Trouble toggle symbols",
    },
    {
      "<leader>tl",
      function() require("trouble").toggle("lsp") end,
      desc = "Trouble toggle lsp",
    },
  },
  cmd = "Trouble",
  opts = {
    preview = {
      type = "split",
      relative = "win",
      position = "right",
      size = 0.3,
    },
    focus = true,
  },
}
