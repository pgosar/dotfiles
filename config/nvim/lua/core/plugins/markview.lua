return {
  "OXY2DEV/markview.nvim",
  cond = group.plugins.markview,
  ft = "markdown",
  keys = {
    {
      "<leader>mm",
      function() require("markview").toggle() end,
      desc = "Toggle markdown viewer",
    },
  },
  opts = {

    latex = {
      enable = false,
    },
    preview = {
      modes = { "n", "i", "no", "c" },
      hybrid_modes = { "i" },
      callbacks = {
        on_enable = function(_, win)
          vim.wo[win].conceallevel = 2
          vim.wo[win].concealcursor = "nc"
        end,
      },
      filetypes = { "markdown" },
    },
    html = { tags = { default = { conceal = true } } },
  },
}
