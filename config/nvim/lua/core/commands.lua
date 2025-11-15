-- update function
vim.api.nvim_create_user_command(
  "CyberUpdate",
  function() require("core.utils.utils").update_all() end,
  { desc = "Updates plugins, mason packages, treesitter parsers" }
)

-- close buffer windows without messing up layout
vim.api.nvim_create_user_command(
  "Bd",
  function() require("snacks").bufdelete() end,
  { desc = "Delete buffer with Snacks" }
)
