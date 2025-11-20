-- Autosave
return {
  "okuuva/auto-save.nvim",
  event = { "InsertEnter", "InsertLeave", "TextChanged" },
  cond = group.plugins.autosave,
  opts = { debounce_delay = require("defaults").plugin_settings.autosave_delay },
}
