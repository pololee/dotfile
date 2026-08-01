local M = {}

local hotkey = nil

function M.start(hyper)
	if hotkey then
		return
	end

	hs.hints.style = "vimperator"
	hs.hints.fontName = "Monaco"
	hs.hints.fontSize = 25
	hs.hints.showTitleThresh = 5

	hotkey = hs.hotkey.bind(hyper, "h", hs.hints.windowHints)
end

function M.stop()
	if hotkey then
		hotkey:delete()
		hotkey = nil
	end
end

return M
