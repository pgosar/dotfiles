local M = {}

local home = os.getenv("HOME")
local monitors_conf_path = home .. "/.config/hypr/monitors.conf"

-- We want to return monitor names and descriptions
M.monitor1 = ""
M.monitor2 = ""

local variables = {}

local f = io.open(monitors_conf_path, "r")
if f then
  for line in f:lines() do
    -- strip comments and spaces
    local content = line:gsub("#.*$", ""):gsub("^%s+", ""):gsub("%s+$", "")
    if content ~= "" then
      -- Variable definition: $name = value
      local var_name, var_val = content:match("^%s*(%$[%w_]+)%s*=%s*(.-)%s*$")
      if var_name then
        variables[var_name] = var_val
        if var_name == "$monitor1" then
          M.monitor1 = var_val
        elseif var_name == "$monitor2" then
          M.monitor2 = var_val
        end
      else
        -- monitor = output, mode, position, scale, ...
        local monitor_args = content:match("^%s*monitor%s*=%s*(.-)%s*$")
        if monitor_args then
          -- split by comma
          local parts = {}
          for part in monitor_args:gmatch("[^,]+") do
            table.insert(parts, part:gsub("^%s+", ""):gsub("%s+$", ""))
          end

          if #parts >= 4 then
            local output = parts[1]
            -- expand variable if starts with $
            if output:sub(1, 1) == "$" then output = variables[output] or output end

            local mode = parts[2]
            local position = parts[3]
            local scale = parts[4]
            -- scale could be number or auto
            if tonumber(scale) then scale = tonumber(scale) end

            local spec = {
              output = output,
              mode = mode,
              position = position,
              scale = scale,
            }

            -- parse additional options: bitdepth, cm, sdrbrightness, etc.
            local i = 5
            while i <= #parts do
              local key = parts[i]
              if key == "bitdepth" then
                spec.bitdepth = tonumber(parts[i + 1])
                i = i + 2
              elseif key == "cm" then
                spec.cm = parts[i + 1]
                i = i + 2
              elseif key == "sdrbrightness" then
                spec.sdrbrightness = tonumber(parts[i + 1])
                i = i + 2
              elseif key == "sdrsaturation" then
                spec.sdrsaturation = tonumber(parts[i + 1])
                i = i + 2
              elseif key == "mirror" then
                spec.mirror = parts[i + 1]
                i = i + 2
              elseif key == "vrr" then
                spec.vrr = tonumber(parts[i + 1]) or parts[i + 1]
                i = i + 2
              else
                -- Boolean or flag options without explicit value
                i = i + 1
              end
            end

            hl.monitor(spec)
          end
        end
      end
    end
  end
  f:close()
end

return M
