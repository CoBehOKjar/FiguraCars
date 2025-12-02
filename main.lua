local state = require("state")
local action_wheel = require("ui.action_wheel")
local render = require("ui.render")
local physic = require("core.physic")
local sound = require("core.sound")



function events.entity_init()
    vanilla_model.ALL:setVisible(false)
    Driver:setPrimaryTexture("SKIN")

    action_wheel.init()
    sound.init()
end



function events.tick()
    if not player:isLoaded() then return end
    physic.tick()
    render.tick()
    
    -- Обновляем звуки (передаем данные из физики)
    -- sound.tick(
    --     player:getPos(), 
    --     state.Data.accelState, 
    --     state.Data.engineRPM
    -- )
end



function events.world_render(delta)
    if not player:isLoaded() then return end
    render.render(delta)
end



--. Еврейская мудрость
-- local outfitEnabled = false

-- function pings.setOutfit(state) -- this state is provided by the host
-- --                  input                 ^
-- --                  vvvvv                 |
--     outfitEnabled = state --              |
-- --  ^^^^^^^^^^^^^                         |
-- --     output                             |
-- end--                                     |
-- --                                        |
-- action:setOnLeftClick(function()--        |
--     pings.setOutfit(not outfitEnabled)----+
-- end)