return {
  "tadmccorkle/markdown.nvim",
  cond = group.plugins.markdown,
  ft = "markdown",
  keys = {
    {
      "<M-CR>",
      "<Cmd>MDListItemBelow<CR>",
      mode = { "n", "i" },
      desc = "Insert new markdown list item below",
    },
  },
  opts = {},
}
