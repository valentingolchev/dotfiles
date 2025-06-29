local wezterm = require("wezterm")
local config = wezterm.config_builder()
local mux = wezterm.mux

wezterm.on("gui-startup", function()
	local tab, pane, window = mux.spawn_window({})
	window:gui_window():maximize()
end)

config.color_scheme = "Catppuccin Mocha" -- Mocha, Macchiato, Frappe, Latte

config.font_dirs = { "fonts" }
config.font = wezterm.font_with_fallback {
	"Hack",
	"Hack Nerd Font Mono",
	"JetBrains Mono",
}
config.font_size = 12

config.enable_tab_bar = false

config.window_decorations = "RESIZE"
config.window_background_opacity = 1.0
config.macos_window_background_blur = 10

config.native_macos_fullscreen_mode = true

config.mouse_bindings = {
	-- CMD-click will open the link under the mouse cursor
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CMD",
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
}

config.keys = {
	{
		key = "n",
		mods = "SHIFT|CTRL",
		action = wezterm.action.ToggleFullScreen,
	},
}

return config
