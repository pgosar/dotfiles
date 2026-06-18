local group = require("defaults").group

require("markdown").setup({})
if group.plugins.markview then
  require("markview").setup({
    latex = { enable = false },
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
  })
end
