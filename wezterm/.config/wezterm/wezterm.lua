local wezterm = require('wezterm')

local function scheme_for_appearance(appearance)
  if appearance:find('Dark') then
    return 'Dark'
  else
    -- return 'Modus-Operandi'
    return 'Catppuccin Latte'
  end
end

wezterm.on('window-config-reloaded', function(window, _)
  local overrides = window:get_config_overrides() or {}
  local appearance = window:get_appearance()
  local scheme = scheme_for_appearance(appearance)
  if overrides.color_scheme ~= scheme then
    overrides.color_scheme = scheme
    window:set_config_overrides(overrides)
  end
end)

return {
  -- window_background_opacity = 0.90,
  -- macos_window_background_blur = 20,
  font = wezterm.font('Menlo'),
  font_size = 13.0,

  harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },

  enable_tab_bar = true,
  use_fancy_tab_bar = false,
  hide_tab_bar_if_only_one_tab = true,

  window_decorations = 'TITLE | RESIZE',

  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },

  use_resize_increments = true,
  initial_cols = 80,
  initial_rows = 24,
  scrollback_lines = 5000,
}
