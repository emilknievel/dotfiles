local wezterm = require('wezterm')

local function scheme_for_appearance(appearance)
  if appearance:find('Dark') then
    return 'Catppuccin Mocha'
  else
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
  window_background_opacity = 0.9,
  macos_window_background_blur = 20,
  font = wezterm.font('MesloLGS Nerd Font'),
  font_size = 13.0,

  harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },

  enable_tab_bar = true,
  use_fancy_tab_bar = false,
  hide_tab_bar_if_only_one_tab = true,

  window_decorations = 'RESIZE',
}
