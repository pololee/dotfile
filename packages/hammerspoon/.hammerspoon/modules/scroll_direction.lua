local M = {}

local eventTap = nil

local function invertMouseWheel(event)
	local properties = hs.eventtap.event.properties
	local isContinuous = event:getProperty(properties.scrollWheelEventIsContinuous)

	-- Trackpads are continuous and should retain macOS's natural direction.
	if isContinuous == 1 then
		return false
	end

	local vertical = event:getProperty(properties.scrollWheelEventDeltaAxis1)
	local horizontal = event:getProperty(properties.scrollWheelEventDeltaAxis2)
	if vertical == 0 or horizontal ~= 0 then
		return false
	end

	local invertedEvent = event:copy()
	invertedEvent:setProperty(properties.scrollWheelEventDeltaAxis1, vertical * -1)

	return true, { invertedEvent }
end

function M.start()
	if eventTap then
		return
	end

	eventTap = hs.eventtap.new({ hs.eventtap.event.types.scrollWheel }, invertMouseWheel)
	eventTap:start()
end

function M.stop()
	if eventTap then
		eventTap:stop()
		eventTap = nil
	end
end

return M
