local state = require("state")

local Render = {}

local function updateSpeedometer()
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

function Render.tick()
    updateSpeedometer()
end

function Render.render(delta)                                               --?Rendering vehicle
    local pos = player:getPos(delta)*16
    F1:setPos(pos[1], pos[2]+7, pos[3])
        :setRot(0,-player:getBodyYaw(delta)-180,0)
end

return Render