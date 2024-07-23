local wezterm = require("wezterm")
local config = wezterm.config_builder()
local mux = wezterm.mux

wezterm.on("gui-startup", function()
	local tab, pane, window = mux.spawn_window({})
	window:gui_window():maximize()
end)

config.color_scheme = "Catppuccin Mocha" -- or Macchiato, Frappe, Latte

config.font = wezterm.font("Hack Nerd Font Mono")
config.font_size = 16

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
