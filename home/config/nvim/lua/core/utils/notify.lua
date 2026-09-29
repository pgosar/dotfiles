-- Shared notification ignore patterns (used by core_init and snacks config).
-- The -32603/-32802 LSP error codes must always stay suppressed.
local M = {}

M.ignore_patterns = {
  "Processing file symbols",
  "Diagnosing",
  "left == right",
  "-32603",
  "-32802",
}

--- Whether a notification message should be suppressed
---@param msg string?: the notification message
---@return boolean ignored: true if the message matches an ignore pattern
M.should_ignore = function(msg)
  if not msg then return false end
  for _, pattern in ipairs(M.ignore_patterns) do
    if msg:find(pattern, 1, true) then return true end
  end
  return false
end

return M
