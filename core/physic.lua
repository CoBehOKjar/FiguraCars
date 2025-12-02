local state = require("state")
local sound = require("core.sound")

local Physic = {}

local cfg = state.Config
local data = state.Data



-- Вспомогательная функция для плавного изменения значений
local function smooth(current, target, factor)
    return current + (target - current) * factor
end


local function stopWheels()
    if cfg.GAS then cfg.GAS:stop() end
    if cfg.REVERSE then cfg.REVERSE:stop() end
end



-- Обновление физики двигателя (обороты, передачи)
local function updateEngine(isAccelerating)
    -- Автоматическое переключение вверх
    if data.currentGear < 6 and data.engineRPM >= cfg.SHIFT_UP_RPM then
        data.currentGear = data.currentGear + 1
        data.engineRPM = cfg.SHIFT_UP_TARGET_RPM
    end

    -- Автоматическое переключение вниз
    -- Используем абсолютное значение скорости для корректного сравнения
    if data.currentGear > 1 and math.abs(data.speedMps) < cfg.gearShiftDownSpeed[data.currentGear] then
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
        -- Используем абсолютное значение скорости для расчета целевых оборотов
        local targetRPM = cfg.IDLE_RPM + (math.abs(data.speedMps) * 50 / cfg.gearRatio[data.currentGear])
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
    local steerInput = 0

    if data.leftState then
        steerInput = steerInput + 1
    end
    if data.rightState then
        steerInput = steerInput - 1
    end

    if data.backState and not data.accelState then
        steerInput = -steerInput
    end

    local targetAngle = steerInput * cfg.MAX_STEER_ANGLE
    data.steerAngle = smooth(data.steerAngle, targetAngle, cfg.STEERING_SMOOTHNESS)
end



-- Обновление анимации колес
local function updateWheelRotation()
    local absSpeed = math.abs(data.speedMps)
    data.isDriving = data.accelState or data.backState -- Нажата ли клавиша газа или заднего хода
    
    local rotationSpeed = 0

    if data.isDriving then
        -- 1. Движение с нажатыми клавишами (зависит от RPM и передачи)
        
        -- Скорость колеса пропорциональна RPM * GearRatio
        -- Используем max(1, data.currentGear) для случая, если передача еще не определена
        rotationSpeed = (data.engineRPM * cfg.gearRatio[data.currentGear]) * cfg.RPM_TO_WHEEL_SPEED_FACTOR

        if data.backState and not data.accelState then
            -- Если нажата только клавиша назад, делаем вращение в 10 раз медленнее
            rotationSpeed = rotationSpeed * cfg.REVERSE_SLOWDOWN_FACTOR
        end

    elseif absSpeed > 0.1 then
        -- 2. Движение накатом (без нажатых клавиш, зависит от текущей скорости)
        rotationSpeed = absSpeed * cfg.COASTING_WHEEL_FACTOR
    end

    -- Если скорость вращения слишком мала, останавливаем анимации и выходим
    if rotationSpeed < 0.01 then
        if cfg.GAS then cfg.GAS:stop() end
        if cfg.REVERSE then cfg.REVERSE:stop() end
        return
    end

    -- 3. Управление анимациями
    local animGas = cfg.GAS
    local animReverse = cfg.REVERSE

    -- Логика для определения направления анимации
    local playForward = false
    local playBackward = false

    -- Приоритет управления
    if data.accelState then
        playForward = true
    elseif data.backState then
        playBackward = true
    else
        -- Если ничего не нажато — используем скорость
        playForward = data.speedMps < -0.1
        playBackward = data.speedMps > 0.1
    end

    if playForward then 
        if animGas then 
            animGas:setSpeed(rotationSpeed)
            animGas:play()
        end
        if animReverse then animReverse:stop() end
    elseif playBackward then 
        if animReverse then
            animReverse:setSpeed(rotationSpeed)
            animReverse:play()
        end
        if animGas then animGas:stop() end
    else
        stopWheels()
    end
end


-- Главная функция тика физики
function Physic.tick()
    local vehicle = player:getVehicle()
    local inVehicle = vehicle ~= nil
    local onGround = inVehicle and vehicle:isOnGround()
    
    data.inVehicle = inVehicle
    data.isVehicleOnGround = onGround

    -- Чтение ввода
    data.accelState = cfg.ACKEY:isPressed()
    data.backState = cfg.BKKEY:isPressed()
    data.leftState = cfg.LFKEY:isPressed()
    data.rightState = cfg.RTKEY:isPressed()

    -- Расчет скорости и ускорения
    local velocity = player:getVelocity()
    
    -- Расчет НАПРАВЛЕННОЙ скорости
    local yaw = math.rad(player:getBodyYaw())
    local bodyDir = vec(math.sin(yaw), 0, -math.cos(yaw))
    local flatVel = vec(velocity.x, 0, velocity.z)
    
    -- Cкалярная скорость вдоль направления движения
    data.speedMps = flatVel:dot(bodyDir) * 20
    
    data.acceleration = data.speedMps - data.prevSpeedMps

    
    if state.Data.inVehicle then
        cfg.STEERING:setSpeed(0)
        cfg.STEERING:setTime(1.0)
        cfg.STEERING:play()
        models.car.F1:setPos(0, 8, 0)
    else
        models.car.F1:setPos(0, 0, 0)
        cfg.STEERING:stop()
    end

    -- Если машина активна, считаем физику
    if state.Data.inVehicle then
        if not data.isEngineOn then
            data.isEngineOn = true
            data.engineRPM = cfg.IDLE_RPM
        end

        updateEngine(data.accelState)
        updateSteering()
        updateWheelRotation()

        -- Применение трансформаций к модели
        local factor = data.steerAngle / cfg.MAX_STEER_ANGLE
        local targetTime = 1.0 + -factor
        cfg.STEERING:setTime(targetTime)
        
    else
        data.isEngineOn = false
        data.engineRPM = 0
        stopWheels()
        end
    end

    -- Сохранение предыдущих значений
    data.prevSpeedMps = data.speedMps


return Physic