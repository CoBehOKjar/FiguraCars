local state = require("state")

local Render = {}

local driverParts = { "LeftLeg", "RightLeg", "LeftArm", "RightArm", "Body" }
local armorParts = { "LEGGINGS_BODY", "LEGGINGS_LEFT_LEG", "LEGGINGS_RIGHT_LEG", "BOOTS_LEFT_LEG", "BOOTS_RIGHT_LEG"}
local segmentRPM = state.Config.MAX_RPM / (#state.Config.RPM_LINE - 1)
local hasWheel = models.car.F1.WorldRoot.Car.Frame.SteeringWheel ~= nil

local function updateSpeed()
    local speed = math.floor(math.abs(state.Data.speedMps))

    if speed > 99 then                                                      --?Max display speed
        speed = 99 
    end

    local tensDigit = math.floor(speed / 10)                    --?Calculating tens and units
    local unitsDigit = speed % 10                                   --?for display speed

    local tensUV = state.Config.SPEED_NUMS[tensDigit + 1]
    local unitsUV = state.Config.SPEED_NUMS[unitsDigit + 1]

    if hasWheel then                 --?Applying speed to speedometer
        Tens:setUV(tensUV)
        Units:setUV(unitsUV)
    end
end

local function updateRPM()
    local index = math.floor(state.Data.engineRPM / segmentRPM) + 1
    index = math.min(math.max(index, 1), #state.Config.RPM_LINE)

    if hasWheel then
        RPM:setUV(state.Config.RPM_LINE[index])
    end
end

local function updateGear()
    if hasWheel then
        Gear:setUV(state.Config.GEAR_LINE[state.Data.currentGear])
    end
end

function Render.tick()
    updateSpeed()
    updateGear()
    updateRPM()

    local showCar = state.Data.inVehicle
    F1:setVisible(showCar)
    renderer:setRenderVehicle(not showCar)

    local driverVisible = not showCar
    for _, part in ipairs(driverParts) do
        if Driver[part] then
            Driver[part]:setVisible(driverVisible)
        end
    end
    for _, part in ipairs(armorParts) do
        vanilla_model[part]:setVisible(driverVisible)
    end
    
    if state.Settings.lowCam and state.Data.inVehicle then
        renderer:setCameraPos(0, -0.3, 0)
    else
        renderer:setCameraPos(0, 0, 0)
    end
end

function Render.render(delta)                                               --?Rendering vehicle
    local pos = player:getPos(delta)*16
    F1:setPos(pos[1], pos[2]+7, pos[3])
        :setRot(0,-player:getBodyYaw(delta)-180,0)
end

return Render