local M = {}

local circle = nil
local timer = nil
local hotkey = nil

local function removeCircle()
	if timer then
		timer:stop()
		timer = nil
	end

	if circle then
		circle:delete()
		circle = nil
	end
end

local function highlightMouse()
	removeCircle()

	local mousePoint = hs.mouse.absolutePosition()
	circle = hs.drawing.circle(hs.geometry.rect(mousePoint.x - 40, mousePoint.y - 40, 100, 100))
	circle:setStrokeColor({ red = 1, green = 0, blue = 0, alpha = 1 })
	circle:setFill(false)
	circle:setStrokeWidth(5)
	circle:show()

	timer = hs.timer.doAfter(3, removeCircle)
end

function M.start(hyper)
	if hotkey then
		return
	end

	hotkey = hs.hotkey.bind(hyper, "D", highlightMouse)
end

function M.stop()
	if hotkey then
		hotkey:delete()
		hotkey = nil
	end

	removeCircle()
end

return M
