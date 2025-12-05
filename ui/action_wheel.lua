local state = require("state")
local stopwatch = require("lib.stopwatch")

local ActionWheel = {}

local cfg = state.Config
local obj = state.Objects
local stgs = state.Settings
local data = state.Data

function ActionWheel.titleUpdate(action, title)
    action:setTitle(title)
end

function ActionWheel.init()
    --.Creating action wheels
    local wheels = {
        action_wheel:newPage("Utilities"),
        action_wheel:newPage("Debug")
    }

    action_wheel:setPage(wheels[1]) --?Default active wheel

    --.Adding navigation buttons to wheels
    for i, wheel in ipairs(wheels) do       --?Calculating next and prevous wheel
        local prevIndex = (i - 2) % #wheels + 1     --?Pervous
        local nextIndex = i % #wheels + 1           --?Next

        local nav = wheel:newAction()   --?Creating navigation button
            :title("< Пред / След >")
            :item("minecraft:spectral_arrow") --TODO сделать иконки
            :onLeftClick(function()
                action_wheel:setPage(wheels[prevIndex])
            end)
            :onRightClick(function()
                action_wheel:setPage(wheels[nextIndex])
            end)

        obj.AW["Nav"..i] = nav
    end

    --.Adding buttons
    local camHeight = wheels[1]:newAction()
        :title("Высота камеры: "..stgs.camHeight)
        :item("minecraft:observer")
        :setOnScroll(ActionWheel.setCamHeight)
    obj.AW.camHeight = camHeight

    local setBox = wheels[1]:newAction()
        :title("Выбрать зону секундомера")
        :item("minecraft:wooden_axe")
        :onLeftClick(function() stopwatch.setBox(1, player:getPos()) end)
        :onRightClick(function() stopwatch.setBox(2, player:getPos()) end)
    obj.AW.camHeight = setBox

    local toggleStopwatch = wheels[1]:newAction()
        :title("Запустить/остановить секундомер")
        :item("minecraft:clock")
        :onLeftClick(function()
            data.isClocking = true
            print("Таймер запущен")
        end)
        :onRightClick(function()
            data.isClocking = false
            data.currentTime = 0
            data.lastTime = 0
            print("Таймер остановлен")
        end)
    obj.AW.camHeight = toggleStopwatch
end



function ActionWheel.setCamHeight(dir)
    if dir > 0 then
        stgs.camHeight = math.min(stgs.camHeight + 0.05, cfg.CAM_MAX_HEIG)
    else
        stgs.camHeight = math.max(stgs.camHeight - 0.05, cfg.CAM_MIN_HEIG)
    end

    ActionWheel.titleUpdate(obj.AW.camHeight, "Высота камеры: "..stgs.camHeight)
end

return ActionWheel