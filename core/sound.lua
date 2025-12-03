local state = require("state")

local Sound = {}

local engineLoop = sounds["car.EngineLoop"]     --?Sounds path
local ignitionSound = sounds["car.Ignition"]

local targetPitch = 1   --?Engine sound target pitch for smooth changing
local currentPitch = 1  --?Current sound pitch
local currentVolume = 1 --?Current sound volume

local isEnginePlaying = false   --?Current engine sound state
local fadeOutActive = false     --?Fade out engine volume, when exit from vehicle
local fadeSpeed = 0.08          --?Speed of fade out


--*Smooth.
local function smooth(a, b, k)
    return a + (b - a) * k
end


--*Set loop to engine sound on initialization
function Sound.init()
    engineLoop:setLoop(true)
end

--*Stop engine sound
function Sound.stopEngine()
    fadeOutActive = true
end


--*Play ignition sound, when you sit in vehicle
function Sound.playIgnition(pos)
    if ignitionSound then
        ignitionSound:setPos(pos):play()
    end
end



--*Engine starting
function Sound.startEngine(pos)
    if not engineLoop or isEnginePlaying then return end
    
    fadeOutActive = false
    currentVolume = 1

    engineLoop:setPos(pos)
        :setVolume(currentVolume)
        :setPitch(currentPitch)
        :play()

    isEnginePlaying = true
end



--*Engine sound properties update
function Sound.updateEngine(pos)
    if not engineLoop then return end
    engineLoop:setPos(pos)  --?Updating position


    local norm = (state.Data.engineRPM - state.Config.IDLE_RPM) / (state.Config.MAX_RPM - state.Config.IDLE_RPM)
    targetPitch = 0.8 + norm * 1.2                                  --?Set the pitch depending on the RPM
    currentPitch = smooth(currentPitch, targetPitch, 0.2)
    engineLoop:setPitch(currentPitch)


    if fadeOutActive then   --?Smooth stop engine sound, when exit from vehicle
        currentVolume = currentVolume - fadeSpeed
        if currentVolume <= 0 then
            currentVolume = 0
            fadeOutActive = false
            isEnginePlaying = false
            engineLoop:stop()
            return
        end
        engineLoop:setVolume(currentVolume)
    else
        engineLoop:setVolume(1)
    end
end

return Sound