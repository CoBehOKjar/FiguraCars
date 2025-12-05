local state = require("state")

local Stopwatch = {}

local cfg = state.Config
local data = state.Data
local input = state.Input
local obj = state.Objects

local boxMin = vec(0,0,0)
local boxMax = vec(0,0,0)

local function isInsideBox(pos)
    return  pos[1] >= boxMin[1] and pos[1] <= boxMax[1]
    and     pos[2] >= boxMin[2] and pos[2] <= boxMax[2]
    and     pos[3] >= boxMin[3] and pos[3] <= boxMax[3]
end

local function vecToString(v)
    return string.format("(%.1f, %.1f, %.1f)", v[1], v[2], v[3])
end


function Stopwatch.setBox(point, pos)
    data.checkBox[point] = pos

    local p1 = data.checkBox[1]
    local p2 = data.checkBox[2]

    boxMin = vec(
        math.min(p1[1], p2[1]),
        math.min(p1[2], p2[2]) - 1,
        math.min(p1[3], p2[3])
    )

    boxMax = vec(
        math.max(p1[1], p2[1]),
        math.max(p1[2], p2[2]) + 1,
        math.max(p1[3], p2[3])
    )

    print("Текущая область: "..vecToString(boxMin).." / "..vecToString(boxMax))
end



function Stopwatch.tick()
    if not data.isClocking then return end

    data.inCheckBox = isInsideBox(player:getPos())

    if data.inCheckBox and not data.wasInCheckBox then
        -- Время круга
        local lapTicks = data.currentTime - data.lastTime
        local lapSec = lapTicks / 20
        local lapMin = math.floor(lapSec / 60)
        local lapSecR = math.floor(lapSec % 60)

        -- Общее время
        local totalSec = data.currentTime / 20
        local totalMin = math.floor(totalSec / 60)
        local totalSecR = math.floor(totalSec % 60)

        -- Обновить последнее время
        data.lastTime = data.currentTime

        print("Lap " .. data.currentLap ..
              " time: " .. lapMin .. "m" .. lapSecR ..
              "s. Total: " .. totalMin .. "m" .. totalSecR .. "s.")

        data.currentLap = data.currentLap + 1
    end

    data.wasInCheckBox = data.inCheckBox
    data.currentTime = data.currentTime + 1
end


return Stopwatch