local wezterm = require("wezterm")

return {
	font = wezterm.font("Iosevka Nerd Font"),
	font_size = 14.0,
	-- freetype_load_flags = "NO_HINTING",

	-- Disable ligatures
	harfbuzz_features = { "calt=0", "clig=0", "liga=0" },

	enable_tab_bar = false,
	window_decorations = "RESIZE",
	-- colors = colors,
	-- color_scheme = "Rosé Pine (Gogh)",
	default_cursor_style = "BlinkingBlock",
	cursor_blink_ease_in = "Constant",
	cursor_blink_ease_out = "Constant",

	front_end = "WebGpu",
}
