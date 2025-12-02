local state = require("state")

local Render = {}

local segmentRPM = state.Config.MAX_RPM / (#state.Config.RPM_LINE - 1)

local function updateSpeed()
    local speed = math.floor(math.abs(state.Data.speedMps))

    if speed > 99 then                                                      --?Max display speed
        speed = 99 
    end

    local tensDigit = math.floor(speed / 10)                    --?Calculating tens and units
    local unitsDigit = speed % 10                                   --?for display speed

    local tensUV = state.Config.SPEED_NUMS[tensDigit + 1]
    local unitsUV = state.Config.SPEED_NUMS[unitsDigit + 1]

    if models.car.F1.WorldRoot.Car.Frame.SteeringWheel then                 --?Applying speed to speedometer
        Tens:setUV(tensUV)
        Units:setUV(unitsUV)
    end
end

local function updateRPM()
    local stateIndex = math.floor(state.Data.engineRPM / segmentRPM) + 1
    local RPMUV = math.max(1, math.min(#state.Config.RPM_LINE, stateIndex))

    if models.car.F1.WorldRoot.Car.Frame.SteeringWheel then
        RPM:setUV(state.Config.RPM_LINE[RPMUV])
    end
end

local function updateGear()
    if models.car.F1.WorldRoot.Car.Frame.SteeringWheel then
        Gear:setUV(state.Config.GEAR_LINE[state.Data.currentGear])
    end
end

function Render.tick()
    updateSpeed()
    updateGear()
    updateRPM()
end

function Render.render(delta)                                               --?Rendering vehicle
    local pos = player:getPos(delta)*16
    F1:setPos(pos[1], pos[2]+7, pos[3])
        :setRot(0,-player:getBodyYaw(delta)-180,0)
end

return Render