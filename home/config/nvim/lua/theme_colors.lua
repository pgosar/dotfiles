-- Seed theme colors (tracked). Generated theme_colors_generated.lua
-- (ignored) overrides this when present. Do not edit the generated file.
local ok, generated = pcall(require, "theme_colors_generated")
if ok and type(generated) == "table" then
  return generated
end

-- Seed fallback: warm dark palette
return {
  base = "#211b1c",
  mantle = "#191415",
  surface = "#2f2728",
  text = "#b2b9b8",
  muted = "#707574",
  white = "#b2b9b8",
  red = "#82adc9",
  green = "#c98282",
  yellow = "#c9a982",
  blue = "#82a9c9",
  purple = "#a982c9",
  peach = "#c98282",
}
