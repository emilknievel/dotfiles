local wezterm = require("wezterm")

return {
	font = wezterm.font("MesloLGS NF"),
	font_size = 13.0,
	freetype_load_flags = "NO_HINTING",

	-- Disable ligatures
	harfbuzz_features = { "calt=0", "clig=0", "liga=0" },

	enable_tab_bar = true,
	use_fancy_tab_bar = true,
	hide_tab_bar_if_only_one_tab = true,
	-- window_decorations = "RESIZE",
	default_cursor_style = "BlinkingBlock",
	cursor_blink_ease_in = "Constant",
	cursor_blink_ease_out = "Constant",

	-- front_end = "WebGpu",
}
