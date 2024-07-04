local wezterm = require('wezterm')

local function get_appearance()
  if wezterm.gui then
    return wezterm.gui.get_appearance()
  end
  return 'Dark'
end

local function scheme_for_appearance(appearance)
  if appearance:find('Dark') then
    return 'Dark'
  else
    return 'Catppuccin Latte'
  end
end

return {
  -- Graphics
  enable_wayland = false,
  color_scheme = scheme_for_appearance(get_appearance()),
  force_reverse_video_cursor = true,

  -- Font features
  font = wezterm.font_with_fallback({ 'NotoSansM Nerd Font' }),
  font_size = 10.0,
  adjust_window_size_when_changing_font_size = true,
  harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },

  -- Windows
  initial_cols = 115,
  initial_rows = 40,
  enable_scroll_bar = false,
  -- window_padding = {
  --   left = 0,
  --   right = 0,
  --   top = 0,
  --   bottom = 0,
  -- },

  -- Tabs
  enable_tab_bar = true,
  use_fancy_tab_bar = false,
  hide_tab_bar_if_only_one_tab = true,

  -- Misc
  scrollback_lines = 50000,
}
