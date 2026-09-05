local config = require("config")

require("modules.config_reloader").start()
require("modules.mouse_highlight").start(config.hyper)
require("modules.window_hints").start(config.hyper)
require("modules.app_hotkeys").start(config.hyper)
require("modules.scroll_direction").start()
require("modules.chrome_vertical_tabs").start(config.chromeVerticalTabs)

hs.alert.show("Config loaded")
