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
      return "Dark"
   else
      return "Terminal Basic"
   end
end

return {
   -- temporarily disable wayland until new nvidia stuff is out
   enable_wayland = false,
   color_scheme = scheme_for_appearance(get_appearance()),
   -- window_background_opacity = 0.9,
   font = wezterm.font("Noto Sans Mono"),
   font_size = 10.0,

   -- Disable ligatures
   harfbuzz_features = { "calt=0", "clig=0", "liga=0" },

   enable_tab_bar = true,
   use_fancy_tab_bar = false,
   hide_tab_bar_if_only_one_tab = true,

   window_decorations = "RESIZE"
}
