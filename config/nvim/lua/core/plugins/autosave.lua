-- Autosave
return {
  "okuuva/auto-save.nvim",
  event = { "InsertEnter", "InsertLeave", "TextChanged" },
  cond = group.plugins.autosave,
  opts = { debounce_delay = 10000 }, -- 10 second delay
}
