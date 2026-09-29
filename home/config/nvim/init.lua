_G.start_time = vim.uv.hrtime()

-- Big-file fast path: a huge file on the CLI gets only minimal options,
-- no plugins or other config. Must run before core_init loads anything.
local bigfile = require("core.bigfile")
if bigfile.is_bigfile(vim.fn.argv(0)) then
  bigfile.setup()
  return
end

require("core_init")
