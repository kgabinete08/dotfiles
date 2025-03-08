local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Font configuration
config.font = wezterm.font("MonoLisa")
config.font_size = 13.0

-- Performance settings for Neovim
config.front_end = "WebGpu" -- Use GPU acceleration
config.webgpu_power_preference = "HighPerformance"
config.animation_fps = 60
config.max_fps = 120
config.enable_scroll_bar = false

-- Color scheme that works well with both tmux and Neovim
config.color_scheme = "Catppuccin Mocha"

-- Window appearance
config.window_padding = {
	left = 2,
	right = 2,
	top = 4,
	bottom = 0,
}
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

-- Terminal compatibility settings - Using standard terminal type
config.term = "xterm-256color"
config.set_environment_variables = {
	TERM = "xterm-256color",
	COLORTERM = "truecolor",
}

-- Audible and visual bell settings (important for vim/neovim notifications)
config.audible_bell = "Disabled"
config.visual_bell = {
	fade_in_duration_ms = 75,
	fade_out_duration_ms = 75,
	target = "CursorColor",
}

-- Settings for quicker startup time and lower latency
config.exit_behavior = "Close"
config.scrollback_lines = 10000 -- Adjust based on your RAM
config.cursor_blink_rate = 800
config.default_cursor_style = "SteadyBlock"

return config
