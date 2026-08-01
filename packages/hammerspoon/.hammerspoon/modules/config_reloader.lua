local M = {}

local watcher = nil

local function containsLuaFile(files)
	for _, file in ipairs(files) do
		if file:sub(-4) == ".lua" then
			return true
		end
	end

	return false
end

function M.start()
	if watcher then
		return
	end

	watcher = hs.pathwatcher.new(hs.configdir, function(files)
		if containsLuaFile(files) then
			hs.reload()
		end
	end)
	watcher:start()
end

function M.stop()
	if watcher then
		watcher:stop()
		watcher = nil
	end
end

return M
