local hyper = {'ctrl', 'cmd'}
local application = require 'hs.application'
local alert = require 'hs.alert'
local hotkey = require 'hs.hotkey'


-- Auto reload the configuration file
function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")


-- Turn down audio volume if it is not home wifi
local wifiWatcher = nil
local homeSSID = "Polo 5GHz"
local lastSSID = hs.wifi.currentNetwork()

function ssidChangedCallback()
  newSSID = hs.wifi.currentNetwork()

  if newSSID == homeSSID and lastSSID ~= homeSSID then
    -- We just joined our home WiFi network
    hs.audiodevice.defaultOutputDevice():setVolume(25)
  elseif newSSID ~= homeSSID and lastSSID == homeSSID then
    hs.audiodevice.defaultOutputDevice():setVolume(0)
  end

  lastSSID = newSSID
end

wifiWatcher = hs.wifi.watcher.new(ssidChangedCallback)
wifiWatcher:start()


-- Draw a circle around mouse
local mouseCircle = nil
local mouseCircleTimer = nil

function mouseHighlight()
    -- Delete an existing highlight if it exists
    if mouseCircle then
        mouseCircle:delete()
        if mouseCircleTimer then
            mouseCircleTimer:stop()
        end
    end
    -- Get the current co-ordinates of the mouse pointer
    mousepoint = hs.mouse.get()
    -- Prepare a big red circle around the mouse pointer
    mouseCircle = hs.drawing.circle(hs.geometry.rect(mousepoint.x-40, mousepoint.y-40, 100, 100))
    mouseCircle:setStrokeColor({["red"]=1,["blue"]=0,["green"]=0,["alpha"]=1})
    mouseCircle:setFill(false)
    mouseCircle:setStrokeWidth(5)
    mouseCircle:show()

    -- Set a timer to delete the circle after 3 seconds
    mouseCircleTimer = hs.timer.doAfter(3, function() mouseCircle:delete() end)
end
hotkey.bind(hyper, "D", mouseHighlight)


-- Show hints
-- hs.hints.style = "vimperator"
hs.hints.fontSize = 30
hs.hints.showTitleThresh = 15
hotkey.bind(hyper, 'h', hs.hints.windowHints)

-- Open applications
local function openiterms2()
  application.launchOrFocus('iTerm')
end
hotkey.bind(hyper, 'i', openiterms2)

local function opengooglechrome(  )
  application.launchOrFocus('Google Chrome')
end
hotkey.bind(hyper, 'c', opengooglechrome)

local function openslack(  )
  application.launchOrFocus('Slack')
end
hotkey.bind(hyper, 's', openslack)

local function openterminal(  )
  application.launchOrFocus('Terminal')
end
hotkey.bind(hyper, 'n', openterminal)

local function opensublime(  )
  application.launchOrFocus('Sublime Text')
end
hotkey.bind(hyper, 'l', opensublime)
