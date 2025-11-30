local state = require("state")
local action_wheel = require("ui.action_wheel")
local physic = require("core.physic")
local sound = require("core.sound")

-- Инициализация при загрузке энтити
function events.entity_init()
    action_wheel.init()
    sound.init()
end

-- Основной цикл (20 раз в секунду)
function events.tick()
    -- Обновляем физику
    physic.tick()
    
    -- Обновляем звуки (передаем данные из физики)
    -- sound.tick(
    --     player:getPos(), 
    --     state.Data.accelState, 
    --     state.Data.engineRPM
    -- )
end

-- HUD и партиклы удалены, поэтому events.render и events.post_render отсутствуют.