local wezterm = require('wezterm')

local function get_appearance()
  if wezterm.gui then
    return wezterm.gui.get_appearance()
  end
  return 'Dark'
end

local function scheme_for_appearance(appearance)
  if appearance:find('Dark') then
    return 'rose-pine'
  else
    return 'rose-pine'
  end
end

return {
  -- Graphics
  enable_wayland = false,
  color_scheme = scheme_for_appearance(get_appearance()),

  -- Font features
  font = wezterm.font('NotoSansM Nerd Font'),
  font_size = 10.0,
  adjust_window_size_when_changing_font_size = false,
  harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },

  -- Windows
  initial_cols = 128,
  initial_rows = 32,

  -- Tabs
  enable_tab_bar = true,
  use_fancy_tab_bar = false,
  hide_tab_bar_if_only_one_tab = true,

  -- Misc
  scrollback_lines = 50000,
}
