_G.start_time = vim.uv.hrtime()

-- Big-file fast path: huge CLI file gets minimal options only, no plugins.
local bigfile = require("core.bigfile")
if bigfile.is_bigfile() then
  bigfile.setup()
  return
end

require("core_init")
