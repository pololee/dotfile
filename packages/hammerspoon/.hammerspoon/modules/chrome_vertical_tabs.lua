-- Adapted from:
-- https://github.com/Ha1baraA11/Chrome-Vertical-Tab-Sidebar-Toggle/blob/main/init-keyboard-only.lua

local M = {}

local defaultLabels = {
	"expand tabs", "collapse tabs", -- English
	"展開分頁", "收合分頁", -- Traditional Chinese
	"展开标签页", "收起标签页", -- Simplified Chinese
	"タブを開く", "タブを閉じる", -- Japanese
	"탭 펼치기", "탭 접기", -- Korean
	"tabs maximieren", "tabs minimieren", -- German
	"mostrar pestañas", "ocultar pestañas", -- Spanish
	"développer les onglets", "réduire les onglets", -- French
	"mostrar guias", "ocultar guias", -- Portuguese (Brazil)
	"развернуть вкладки", "свернуть вкладки", -- Russian
}

local state = {
	running = false,
	keyTap = nil,
	appWatcher = nil,
	caffeinateWatcher = nil,
	graceTimer = nil,
	timers = {},
	debugHotkeys = {},
	totalEventCount = 0,
	inGracePeriod = false,
	config = nil,
}

local function log(message)
	if state.config.debug then
		print("[ChromeVerticalTabs] " .. message)
	end
end

local function schedule(delay, callback)
	local scheduledTimer
	scheduledTimer = hs.timer.doAfter(delay, function()
		state.timers[scheduledTimer] = nil
		if state.running then
			callback()
		end
	end)
	state.timers[scheduledTimer] = true
	return scheduledTimer
end

local function setGracePeriod(seconds)
	state.inGracePeriod = true
	if state.graceTimer then
		state.graceTimer:stop()
	end

	state.graceTimer = hs.timer.doAfter(seconds, function()
		state.graceTimer = nil
		state.inGracePeriod = false
		log("Grace period ended")
	end)
	log("Grace period: " .. seconds .. "s")
end

local function findSidebarButton(element, depth)
	depth = depth or 0
	if not element or depth > 25 then
		return nil
	end

	if element:attributeValue("AXRole") == "AXButton" then
		local title = string.lower(tostring(element:attributeValue("AXTitle") or ""))
		local description = string.lower(tostring(element:attributeValue("AXDescription") or ""))

		for _, label in ipairs(state.config.sidebarLabels) do
			if title == label or description == label then
				return element
			end
		end
	end

	local children = element:attributeValue("AXChildren")
	if children then
		for _, child in ipairs(children) do
			local result = findSidebarButton(child, depth + 1)
			if result then
				return result
			end
		end
	end

	return nil
end

local function toggleSidebar()
	local frontApp = hs.application.frontmostApplication()
	if not frontApp or frontApp:name() ~= state.config.appName or state.inGracePeriod then
		return
	end

	local axApp = hs.axuielement.applicationElement(frontApp)
	local windows = axApp and axApp:attributeValue("AXWindows")
	if not windows or #windows == 0 then
		log("No Chrome windows found")
		return
	end

	for _, window in ipairs(windows) do
		local button = findSidebarButton(window)
		if button then
			button:performAction("AXPress")
			log("Sidebar toggled via Accessibility API")
			return
		end
	end

	log("Sidebar button not found in Accessibility tree")
end

local function shortcutMatches(event)
	local requiredModifiers = { cmd = false, ctrl = false, alt = false, shift = false }
	for _, modifier in ipairs(state.config.shortcut.modifiers) do
		requiredModifiers[modifier] = true
	end

	local flags = event:getFlags()
	for modifier, required in pairs(requiredModifiers) do
		if (flags[modifier] == true) ~= required then
			return false
		end
	end

	return event:getKeyCode() == hs.keycodes.map[state.config.shortcut.key]
end

local function startKeyTap()
	if state.keyTap and state.keyTap:isEnabled() then
		return
	end

	if state.keyTap then
		state.keyTap:stop()
		state.keyTap = nil
	end

	state.keyTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
		state.totalEventCount = state.totalEventCount + 1

		local frontApp = hs.application.frontmostApplication()
		if not frontApp or frontApp:name() ~= state.config.appName or state.inGracePeriod then
			return false
		end

		if shortcutMatches(event) then
			log("Sidebar shortcut intercepted")
			toggleSidebar()
			return true
		end

		return false
	end)
	state.keyTap:start()
	log("Key tap started")
end

local function stopKeyTap()
	if state.keyTap and state.keyTap:isEnabled() then
		state.keyTap:stop()
		log("Key tap stopped")
	end
end

local function restartKeyTap()
	stopKeyTap()
	schedule(0.5, startKeyTap)
end

local function showStatus()
	local frontApp = hs.application.frontmostApplication()
	local status = string.format(
		"Chrome vertical tabs\nApp: %s\nKey tap: %s\nEvents: %d\nGrace: %s",
		frontApp and frontApp:name() or "None",
		state.keyTap and state.keyTap:isEnabled() and "running" or "stopped",
		state.totalEventCount,
		state.inGracePeriod and "yes" or "no"
	)

	hs.alert.show(status, 5)
	log("Status: " .. status:gsub("\n", ", "))
end

local function dumpChromeButtons()
	local frontApp = hs.application.frontmostApplication()
	if not frontApp or frontApp:name() ~= state.config.appName then
		hs.alert.show("Chrome is not frontmost", 3)
		return
	end

	local axApp = hs.axuielement.applicationElement(frontApp)
	local windows = axApp and axApp:attributeValue("AXWindows")
	if not windows or #windows == 0 then
		hs.alert.show("No Chrome windows", 3)
		return
	end

	local results = {}
	local function collectButtons(element, depth)
		if not element or depth > 15 then
			return
		end

		if element:attributeValue("AXRole") == "AXButton" then
			table.insert(results, string.format(
				"Title: [%s] | Desc: [%s] | Help: [%s]",
				tostring(element:attributeValue("AXTitle")),
				tostring(element:attributeValue("AXDescription")),
				tostring(element:attributeValue("AXHelp"))
			))
		end

		local children = element:attributeValue("AXChildren")
		if children then
			for _, child in ipairs(children) do
				collectButtons(child, depth + 1)
			end
		end
	end

	for _, window in ipairs(windows) do
		collectButtons(window, 0)
	end

	print("=== Chrome Accessibility Buttons ===")
	for index, result in ipairs(results) do
		print(index .. ". " .. result)
	end
	print("=== Total: " .. #results .. " buttons ===")
	hs.alert.show("Found " .. #results .. " buttons; check the Hammerspoon Console", 3)
end

local function startDebugHotkeys()
	if not state.config.debug then
		return
	end

	state.debugHotkeys = {
		hs.hotkey.bind({ "cmd", "alt" }, "D", showStatus),
		hs.hotkey.bind({ "cmd", "alt" }, "B", dumpChromeButtons),
		hs.hotkey.bind({ "cmd", "alt" }, "R", function()
			hs.alert.show("Restarting Chrome vertical-tabs key tap", 2)
			restartKeyTap()
		end),
	}
end

local function applyDefaults(options)
	options = options or {}
	local shortcut = options.shortcut or {}

	return {
		appName = options.appName or "Google Chrome",
		debug = options.debug == true,
		shortcut = {
			modifiers = shortcut.modifiers or { "cmd" },
			key = shortcut.key or "s",
		},
		sidebarLabels = options.sidebarLabels or defaultLabels,
	}
end

function M.start(options)
	if state.running then
		return
	end

	state.config = applyDefaults(options)
	state.running = true
	setGracePeriod(2)
	startKeyTap()

	state.appWatcher = hs.application.watcher.new(function(appName, eventType)
		if appName ~= state.config.appName then
			return
		end

		local watcher = hs.application.watcher
		if eventType == watcher.activated then
			setGracePeriod(1.5)
			schedule(0.5, startKeyTap)
		elseif eventType == watcher.deactivated then
			setGracePeriod(1)
			schedule(0.3, stopKeyTap)
		elseif eventType == watcher.launched then
			setGracePeriod(2)
		elseif eventType == watcher.terminated then
			stopKeyTap()
		end
	end)
	state.appWatcher:start()

	state.caffeinateWatcher = hs.caffeinate.watcher.new(function(eventType)
		local watcher = hs.caffeinate.watcher
		if eventType == watcher.systemDidWake then
			setGracePeriod(3)
			schedule(2, restartKeyTap)
		elseif eventType == watcher.systemWillSleep then
			stopKeyTap()
		end
	end)
	state.caffeinateWatcher:start()

	startDebugHotkeys()
	schedule(2, function()
		startKeyTap()
		log("Chrome vertical-tabs service initialized")
	end)
end

function M.stop()
	state.running = false

	if state.appWatcher then
		state.appWatcher:stop()
		state.appWatcher = nil
	end
	if state.caffeinateWatcher then
		state.caffeinateWatcher:stop()
		state.caffeinateWatcher = nil
	end
	if state.graceTimer then
		state.graceTimer:stop()
		state.graceTimer = nil
	end

	for timer in pairs(state.timers) do
		timer:stop()
	end
	state.timers = {}

	for _, hotkey in ipairs(state.debugHotkeys) do
		hotkey:delete()
	end
	state.debugHotkeys = {}

	stopKeyTap()
	state.keyTap = nil
	state.inGracePeriod = false
end

return M
