local wezterm = require "wezterm"

-- Dynamically set theme based on OS appearance.
-- TODO: Use when dynamic theming solved for other utils.
function scheme_for_appearance(appearance)
  if appearance:find "Dark" then
    return "Catppuccin Mocha"
  else
    return "Catppuccin Latte"
  end
end

return {
  font = wezterm.font "BlexMono Nerd Font",
  font_size = 14.0,
  enable_tab_bar = false,
  window_decorations = "RESIZE",
  -- color_scheme = scheme_for_appearance(wezterm.gui.get_appearance()),
  color_scheme = "Catppuccin Frappe",
}
