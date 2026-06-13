local group = require("defaults").group
local dashboard_config = {
  enabled = true,
  preset = {
    header = require("defaults").dashboard_ascii,
    keys = {
      {
        icon = icons.dashboard.recent,
        key = "f",
        desc = "Files",
        action = function() Snacks.dashboard.pick("files") end,
      },
      {
        icon = icons.dashboard.recent,
        key = "r",
        desc = "Recent Files",
        action = function() Snacks.dashboard.pick("oldfiles") end,
      },
      {
        icon = icons.dashboard.new_file,
        key = "n",
        desc = "New File",
        action = require("core.utils.utils").create_new_file,
      },
      {
        icon = icons.dashboard.find,
        key = "g",
        desc = "Find Text",
        action = function() Snacks.dashboard.pick("live_grep") end,
      },
      {
        icon = icons.dashboard.config,
        key = "c",
        desc = "Config",
        action = function() Snacks.dashboard.pick("files", { cwd = vim.fn.stdpath("config") }) end,
      },
      {
        icon = icons.dashboard.session,
        key = "s",
        desc = "Restore Session",
        action = function() require("core.utils.session").load_session() end,
      },
      {
        icon = icons.dashboard.quit,
        key = "q",
        desc = "Quit",
        action = function() vim.cmd("qa") end,
      },
    },
  },
  sections = {
    { section = "header" },
    { section = "keys", gap = 1, padding = 1 },
    {
      pane = 2,
      icon = icons.dashboard.new_file,
      title = "Recent Files",
      section = "recent_files",
      indent = 2,
      padding = 1,
    },
    {
      pane = 2,
      icon = icons.dashboard.open_project,
      title = "Projects",
      section = "projects",
      indent = 2,
      padding = 1,
    },
    {
      pane = 2,
      icon = icons.git.branch,
      title = "Git Status",
      section = "terminal",
      enabled = function() return Snacks.git.get_root() ~= nil end,
      cmd = "git status --short --branch --renames",
      height = 5,
      padding = 1,
      ttl = 5 * 60,
      indent = 3,
    },
    {
      title = "Open Issues",
      cmd = "gh issue list -L 3",
      key = "i",
      action = function() vim.fn.jobstart("gh issue list --web", { detach = true }) end,
      icon = " ",
      height = 7,
    },
    function()
      local plugins = require("core.plugins")
      local total = #plugins
      local loaded = 0
      for _, p in ipairs(plugins) do
        if not p.lazy then loaded = loaded + 1 end
      end
      local ms = 0
      if _G.start_time then
        ms = (vim.uv.hrtime() - _G.start_time) / 1e6
        ms = math.floor(ms * 100 + 0.5) / 100
      end
      return {
        align = "center",
        text = {
          { "⚡ Neovim loaded ", hl = "footer" },
          { tostring(loaded) .. "/" .. tostring(total), hl = "special" },
          { " plugins in ", hl = "footer" },
          { tostring(ms) .. "ms", hl = "special" },
        },
      }
    end,
  },
}

require("snacks").setup({
  notifier = { enabled = group.plugins.notify },
  picker = { enabled = group.plugins.snack_picker },
  zen = { enabled = group.plugins.snack_zen, toggles = { dim = false } },
  dashboard = {
    enabled = group.plugins.snack_dashboard,
    preset = dashboard_config.preset,
    sections = dashboard_config.sections,
  },
  bufdelete = { enabled = group.plugins.snack_bufdelete },
  statuscolumn = { enabled = group.plugins.snack_statuscolumn },
  rename = { enabled = group.plugins.snack_rename },
  image = { enabled = group.plugins.snack_image },
})

if group.plugins.notify then
  local original_notify = vim.notify
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.notify = function(msg, level, opts)
    local ignore_patterns = {
      "Processing file symbols",
      "Diagnosing",
      "left == right",
      "-32603",
      "-32802",
    }
    for _, pattern in ipairs(ignore_patterns) do
      if msg and msg:find(pattern, 1, true) then return end
    end
    original_notify(msg, level, opts)
  end
end
