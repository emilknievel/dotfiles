local wezterm = require "wezterm"

-- Dynamically set theme based on OS appearance.
-- TODO: Use when dynamic theming solved for other utils.
function scheme_for_appearance(appearance)
  if appearance:find "Dark" then
    return "Catppuccin Frappe"
  else
    return "Catppuccin Latte"
  end
end

return {
  font = wezterm.font "FiraCode Nerd Font",
  font_size = 10.0,
  -- freetype_load_flags = "NO_HINTING",

  -- Disable ligatures
  -- harfbuzz_features = {"calt=0", "clig=0", "liga=0"},

  enable_tab_bar = false,
  -- window_decorations = "RESIZE",
  -- color_scheme = scheme_for_appearance(wezterm.gui.get_appearance()),
  color_scheme = "Catppuccin Frappe",
  default_cursor_style = "BlinkingBlock",
  cursor_blink_ease_in = "Constant",
  cursor_blink_ease_out = "Constant",

  front_end = "WebGpu",
}
