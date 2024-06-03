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
    return 'Terminal Basic'
  end
end

return {
  color_scheme = scheme_for_appearance(get_appearance()),

  font = wezterm.font('NotoSansM Nerd Font'),
  font_size = 10.0,
  harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },

  enable_tab_bar = true,
  use_fancy_tab_bar = false,
  hide_tab_bar_if_only_one_tab = true,

  enable_wayland = false,

  scrollback_lines = 50000,
}
