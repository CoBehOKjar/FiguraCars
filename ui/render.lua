local state = require("state")

local Render = {}

local driverParts = { "LeftLeg", "RightLeg", "LeftArm", "RightArm", "Body" }                                            --?Parts of model for hidding, when in car
local armorParts = { "LEGGINGS_BODY", "LEGGINGS_LEFT_LEG", "LEGGINGS_RIGHT_LEG", "BOOTS_LEFT_LEG", "BOOTS_RIGHT_LEG"}   --?Parts of vanilla armor for hidding, when in car
local segmentRPM = state.Config.MAX_RPM / (#state.Config.RPM_UV - 1)        --?RPM in one pixel of indicator on steering wheel
local hasWheel = models.car.F1.WorldRoot.Car.Frame.SteeringWheel ~= nil     --?Check, what steering wheel exist



--*Updating speed on speedometer
local function updateSpeed()
    local speed = math.floor(math.abs(state.Data.speedMps)) --?Getting a natural speed number

    if speed > 99 then                                                      --?Max display speed
        speed = 99 
    end

    local tensDigit = math.floor(speed / 10)                    --?Calculating tens and units for display speed
    local unitsDigit = speed % 10

    local tensUV = state.Config.SPEED_UV[tensDigit + 1]
    local unitsUV = state.Config.SPEED_UV[unitsDigit + 1]

    if hasWheel then                                                        --?Applying speed to speedometer
        Tens:setUV(tensUV)
        Units:setUV(unitsUV)
    end
end


--*Updating RPM on speedometer
local function updateRPM()
    local index = math.floor(state.Data.engineRPM / segmentRPM) + 1
    index = math.min(math.max(index, 1), #state.Config.RPM_UV)

    if hasWheel then
        RPM:setUV(state.Config.RPM_UV[index])
    end
end


--*Updating Gear on speedometer
local function updateGear()
    if hasWheel then
        Gear:setUV(state.Config.GEAR_UV[state.Data.currentGear])
    end
end



--*Main tick function
function Render.tick()
    --.Speedometer update
    updateSpeed()
    updateGear()
    updateRPM()


    --.Model parts visibility update
    F1:setVisible(state.Data.inVehicle)                 --?Show car
    renderer:setRenderVehicle(not state.Data.inVehicle) --?And hide boat

    local driverVisible = not state.Data.inVehicle      --?Hidding parts of model that extend beyond the textures
    for _, part in ipairs(driverParts) do
        if Driver[part] then
            Driver[part]:setVisible(driverVisible)
        end
    end
    for _, part in ipairs(armorParts) do                --?Hidding parts of vanilla armor that extend beyond the textures
        vanilla_model[part]:setVisible(driverVisible)
    end
    vanilla_model.CAPE:setVisible(driverVisible)            --?And cape
    

    --.Camera position update
    if state.Data.inVehicle then    --?Set camera height, what needed, when in car
        renderer:setCameraPos(0, state.Settings.camHeight, 0)
    else
        renderer:setCameraPos(0, 0, 0)
    end
end


--*Rendering car in player position
function Render.render(delta)
    local pos = player:getPos(delta)*16
    F1:setPos(pos[1], pos[2]+7, pos[3]) --?+7 because player is under the block the boat is on
        :setRot(0,-player:getBodyYaw(delta)-180,0)
end

return Render