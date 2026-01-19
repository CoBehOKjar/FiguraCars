-- ==========================================================
-- === НАСТРОЙКИ РАДАРА И ТРАССЫ ===
-- ==========================================================

local TARGET_NAMES = {"CoBeHok", "Anzorik", "Poxyie"} -- Список игроков для слежки
local RING_RADIUS = 96.0 
local RING_PARTICLE = "minecraft:flame"
local RING_SPAWN_DELAY = 10 -- Задержка круга (тики)

-- Настройки зон (боксов)
local BOX_RENDER_DELAY = 10 -- Задержка отрисовки боксов (тики)
local BOX_DENSITY = 0.5     -- Плотность частиц (на 1 блок)

local sectors = {
    {
        id = "S1",
        inBox = {vec(605,70,-2189), vec(629,76,-2185)},
        outBox = {vec(579,70,-2505), vec(618,76,-2500)},
    },
    {
        id = "S2",
        inBox = {vec(496,70,-2061), vec(524,76,-2054)},
        outBox = {vec(399,70,-1884), vec(411,76,-1850)},
    },
    {
        id = "S3",
        inBox = {vec(439,70,-1897), vec(445,76,-1877)},
        outBox = {vec(558,70,-1813), vec(589,76,-1806)},
    },
}

local finish = {
    id = "F1",
    box = {vec(581,70,-2036), vec(604,76,-2030)}
}

local pitStop = {
    id = "P1",
    inBox = {vec(596,70,-1863), vec(606,76,-1848)},
    outBox = {vec(612,0,-2096), vec(624,76,-2091)},
}

-- ==========================================================
-- === СЛУЖЕБНЫЕ ПЕРЕМЕННЫЕ ===
-- ==========================================================

local ticks = 0
local lastDistances = {}

-- === ФУНКЦИЯ ОТРИСОВКИ БОКСОВ ===
local function drawBox(minV, maxV, particleID)
    -- Рисуем контур нижней (Y min) и верхней (Y max) плоскостей
    local ys = {minV.y, maxV.y}
    for _, y in ipairs(ys) do
        -- Линии по X
        for x = minV.x, maxV.x, 1/BOX_DENSITY do
            particles:newParticle(particleID, x, y, minV.z)
            particles:newParticle(particleID, x, y, maxV.z)
        end
        -- Линии по Z
        for z = minV.z, maxV.z, 1/BOX_DENSITY do
            particles:newParticle(particleID, minV.x, y, z)
            particles:newParticle(particleID, maxV.x, y, z)
        end
    end
end

-- === ОСНОВНОЙ ЦИКЛ ===
function events.tick()
    ticks = ticks + 1
    local players = world.getPlayers()
    local actionBarText = "§7Radar: "

    -- == 1. ЛОГИКА РАДАРА И КОЛЕЦ ==
    local showRing = (ticks % RING_SPAWN_DELAY == 0)

    for i, name in ipairs(TARGET_NAMES) do
        local target = players[name]
        local color = "§c"
        local distText = "LOST"

        if target and target:isLoaded() then
            local myPos = player:getPos()
            local hisPos = target:getPos()
            
            -- Дистанция
            local dx = myPos.x - hisPos.x
            local dy = myPos.y - hisPos.y
            local dz = myPos.z - hisPos.z
            local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
            
            color = "§a"
            distText = string.format("%.1fm", dist)

            -- Кольцо вокруг игрока
            if showRing then
                for j = 0, 80 do -- Фиксированное кол-во для стабильности
                    local angle = (j / 80) * 2 * math.pi
                    local px = hisPos.x + RING_RADIUS * math.cos(angle)
                    local pz = hisPos.z + RING_RADIUS * math.sin(angle)
                    particles:newParticle(RING_PARTICLE, px, hisPos.y + 1, pz):scale(5)
                end
            end
        end
        actionBarText = actionBarText .. string.format("§e%s§7: %s%s ", name, color, distText)
        if i < #TARGET_NAMES then actionBarText = actionBarText .. "§8| " end
    end
    host:setActionbar(actionBarText)

    -- == 2. ЛОГИКА ОТРИСОВКИ ЗОН ТРАССЫ ==
    if ticks % BOX_RENDER_DELAY == 0 then
        -- Сектора (Белые искры)
        for _, s in ipairs(sectors) do
            drawBox(s.inBox[1], s.inBox[2], "minecraft:end_rod")
            drawBox(s.outBox[1], s.outBox[2], "minecraft:end_rod")
        end
        -- Финиш (Огонь)
        drawBox(finish.box[1], finish.box[2], "minecraft:wax_on")
        -- Пит-лейн (Электричество)
        drawBox(pitStop.inBox[1], pitStop.inBox[2], "minecraft:cloud")
        drawBox(pitStop.outBox[1], pitStop.outBox[2], "minecraft:cloud")
    end
end