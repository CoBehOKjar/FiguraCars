local state = require("state")
local sound = require("core.sound")

local Physic = {}

-- Локальные ссылки для удобства
local cfg = state.Config
local data = state.Data


-- Вспомогательная функция для плавного изменения значений
local function smooth(current, target, factor)
    return current + (target - current) * factor
end

-- Обновление физики двигателя (обороты, передачи)
local function updateEngine(isAccelerating)
    -- Автоматическое переключение вверх
    if data.currentGear < 6 and data.engineRPM >= cfg.SHIFT_UP_RPM then
        data.currentGear = data.currentGear + 1
        data.engineRPM = cfg.SHIFT_UP_TARGET_RPM
    end

    -- Автоматическое переключение вниз
    if data.currentGear > 1 and data.speedMps < cfg.gearShiftDownSpeed[data.currentGear] then
        local rpmBeforeShift = data.engineRPM
        data.currentGear = data.currentGear - 1
        
        -- Эмуляция перегазовки
        if rpmBeforeShift < cfg.SHIFT_DOWN_BLIP_RPM then
            data.engineRPM = math.min(cfg.SHIFT_DOWN_BLIP_RPM, cfg.MAX_RPM)
            sound.playDownshift(player:getPos())
        end
    end

    -- Расчет оборотов
    if isAccelerating then
        local rpmIncrease = cfg.RPM_ACCEL_BASE_RATE * (cfg.gearRatio[data.currentGear] / cfg.gearRatio[1])
        data.engineRPM = data.engineRPM + rpmIncrease
    else
        -- Торможение двигателем
        local targetRPM = cfg.IDLE_RPM + (data.speedMps * 50 / cfg.gearRatio[data.currentGear])
        if data.acceleration < -0.01 and data.engineRPM > targetRPM then
            data.engineRPM = smooth(data.engineRPM, targetRPM, cfg.RPM_DECEL_RATE)
        elseif data.engineRPM > cfg.IDLE_RPM then
            data.engineRPM = data.engineRPM - 100
        end
    end

    -- Ограничители
    data.engineRPM = math.max(cfg.IDLE_RPM, math.min(cfg.MAX_RPM, data.engineRPM))
end

-- Обновление рулевого управления
local function updateSteering()
    if data.speedMps <= 0.1 then return end

    local velocity = player:getVelocity()
    local yaw = math.rad(player:getBodyYaw())
    local bodyDir = vec(math.sin(yaw), 0, -math.cos(yaw))
    local rightDir = vec(bodyDir.z, 0, -bodyDir.x)
    local flatVel = vec(velocity.x, 0, velocity.z)
    
    -- Вычисляем боковое скольжение для поворота колес
    local sidewaysSpeed = flatVel:dot(rightDir)
    
    local targetAngle = -math.max(-cfg.MAX_STEER_ANGLE, math.min(cfg.MAX_STEER_ANGLE, sidewaysSpeed * cfg.STEERING_SENSITIVITY))
    data.steerAngle = targetAngle
end

-- Обновление подвески (вертикальное положение колес)
local function updateSuspension()
    local onGround = data.isVehicleOnGround
    
    -- Целевые позиции колес (без крена, только вверх/вниз)
    local targetFR = onGround and cfg.GROUND_WHEEL_Z or -cfg.AIR_WHEEL_Z
    local targetFL = onGround and -cfg.GROUND_WHEEL_Z or cfg.AIR_WHEEL_Z
    local targetRL = onGround and cfg.GROUND_WHEEL_Z or -cfg.AIR_WHEEL_Z
    local targetRR = onGround and -cfg.GROUND_WHEEL_Z or cfg.AIR_WHEEL_Z

    data.wheelZ.FR = smooth(data.wheelZ.FR, targetFR, cfg.WHEEL_Z_SMOOTH)
    data.wheelZ.FL = smooth(data.wheelZ.FL, targetFL, cfg.WHEEL_Z_SMOOTH)
    data.wheelZ.RL = smooth(data.wheelZ.RL, targetRL, cfg.WHEEL_Z_SMOOTH)
    data.wheelZ.RR = smooth(data.wheelZ.RR, targetRR, cfg.WHEEL_Z_SMOOTH)
end

-- Главная функция тика физики
function Physic.tick()
    if not player:isLoaded() then return end

    -- Определение состояния игрока и транспорта
    local vehicle = player:getVehicle()
    local inVehicle = false
    local onGround = player:isOnGround()

    if vehicle then
        -- Простая проверка, сидит ли игрок в лодке/вагонетке
        inVehicle = true
        onGround = vehicle:isOnGround()
    end
    
    data.inVehicle = inVehicle
    data.isVehicleOnGround = onGround

    -- Чтение ввода (газ)
    local accelKey = keybinds:fromVanilla("key.forward")
    data.accelState = accelKey:isPressed()

    -- Расчет скорости и ускорения
    local velocity = player:getVelocity()
    data.speedMps = velocity:length() * 20
    data.acceleration = data.speedMps - data.prevSpeedMps

    -- Логика включения/отображения машины
    local showCar = inVehicle -- Машина видна, только если мы внутри транспорта
    F1:setVisible(showCar)
    renderer:setRenderVehicle(not showCar) -- Скрываем ванильный транспорт

    -- Управление видимостью игрока (сидя в болиде)
    if showCar then
        animations["car.F1"].Steering:play()
        models.car.F1:setPos(0, 6, 0)
    else
        models.car.F1:setPos(0, 0, 0)
    end

    -- Если машина активна, считаем физику
    if showCar then
        if not data.isEngineOn then
            data.isEngineOn = true
            data.engineRPM = cfg.IDLE_RPM
        end

        updateEngine(data.accelState)
        updateSteering()
        updateSuspension()

        -- Применение трансформаций к модели
        local car = F1.Car.Frame
        car.WheelFR:setRot(0, data.steerAngle, data.wheelZ.FR)
        car.WheelFL:setRot(0, data.steerAngle, data.wheelZ.FL)
        car.WheelBL:setRot(0, 0, -data.wheelZ.RL)
        car.WheelBR:setRot(0, 0, -data.wheelZ.RR)
        
        -- Вращение колес (анимация)
        local wheelSpeed = data.speedMps * 5 -- Множитель скорости вращения
        -- Здесь должна быть анимация вращения текстуры или кости, если она есть
        
    else
        data.isEngineOn = false
        data.engineRPM = 0
    end

    -- Сохранение предыдущих значений
    data.prevSpeedMps = data.speedMps
    data.prevEngineRPM = data.engineRPM
end

return Physic