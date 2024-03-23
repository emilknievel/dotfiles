local wezterm = require("wezterm")

-- wezterm.gui is not available to the mux server, so take care to
-- do something reasonable when this config is evaluated by the mux
local function get_appearance()
   if wezterm.gui then
      return wezterm.gui.get_appearance()
   end
   return "Dark"
end

local function scheme_for_appearance(appearance)
   if appearance:find("Dark") then
      return "Chalk (base16)"
   else
      return "Cupertino (base16)"
   end
end

return {
   color_scheme = scheme_for_appearance(get_appearance()),
   font = wezterm.font("SFMono Nerd Font"),
   font_size = 12.0,
   freetype_load_target = "Light",
   freetype_render_target = "HorizontalLcd",
   freetype_load_flags = "NO_HINTING",

   -- Disable ligatures
   harfbuzz_features = { "calt=0", "clig=0", "liga=0" },

   enable_tab_bar = true,
   use_fancy_tab_bar = true,
   hide_tab_bar_if_only_one_tab = true,

   window_decorations = "RESIZE",
   default_cursor_style = "BlinkingBlock",
   cursor_blink_ease_in = "Constant",
   cursor_blink_ease_out = "Constant",
}
