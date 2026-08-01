local M = {}

local hotkeys = {}

local applications = {
	{ key = "o", name = "Google Chrome" },
	{ key = "s", name = "ChatGPT" },
	{ key = ";", name = "Visual Studio Code" },
	{ key = "i", name = "Ghostty" },
}

function M.start(hyper)
	if #hotkeys > 0 then
		return
	end

	for _, application in ipairs(applications) do
		local appName = application.name
		table.insert(hotkeys, hs.hotkey.bind(hyper, application.key, function()
			hs.application.launchOrFocus(appName)
		end))
	end
end

function M.stop()
	for _, hotkey in ipairs(hotkeys) do
		hotkey:delete()
	end

	hotkeys = {}
end

return M
