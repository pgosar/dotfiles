return {
  "RRethy/vim-illuminate",
  cond = group.plugins.illuminate,
  event = "VeryLazy",
  config = function() require("illuminate").configure({ min_count_to_highlight = 2 }) end,
}
