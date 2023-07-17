local wezterm = require "wezterm"

local colors = require("lua/rose-pine").colors()
local window_frame = require("lua/rose-pine").window_frame()

return {
  font = wezterm.font "BlexMono Nerd Font",
  font_size = 11.0,
  freetype_load_flags = "NO_HINTING",

  -- Disable ligatures
  harfbuzz_features = { "calt=0", "clig=0", "liga=0" },

  enable_tab_bar = false,
  window_decorations = "RESIZE",
  colors = colors,
  default_cursor_style = "BlinkingBlock",
  cursor_blink_ease_in = "Constant",
  cursor_blink_ease_out = "Constant",

  front_end = "WebGpu",

}
