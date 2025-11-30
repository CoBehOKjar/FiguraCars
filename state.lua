local State = {}

-- --- Константы настройки (Config) ---

-- Настройки двигателя и трансмиссии
State.Config = {
    IDLE_RPM = 800,               -- Холостые обороты
    MAX_RPM = 12000,              -- Максимальные обороты (повышено для Ф1)
    RPM_ACCEL_BASE_RATE = 250,    -- Скорость набора оборотов
    RPM_DECEL_RATE = 0.15,        -- Скорость сброса оборотов
    
    -- Обороты переключения передач
    SHIFT_UP_RPM = 11500,         -- Переключение вверх
    SHIFT_UP_TARGET_RPM = 7000,   -- Обороты после переключения вверх
    SHIFT_DOWN_BLIP_RPM = 9000,   -- Подгазовка при понижении

    -- Скорости для автоматического понижения передачи (м/с)
    gearShiftDownSpeed = {
        [1] = 0,
        [2] = 10,
        [3] = 20,
        [4] = 35,
        [5] = 50,
        [6] = 70 -- Добавлена 6 передача для Ф1
    },

    -- Передаточные числа
    gearRatio = {
        [1] = 4.5,
        [2] = 3.2,
        [3] = 2.4,
        [4] = 1.8,
        [5] = 1.4,
        [6] = 1.1
    },

    -- Рулевое управление
    STEERING_SENSITIVITY = 45,
    MAX_STEER_ANGLE = 45, -- Уменьшен угол для Ф1

    -- Подвеска (настроена жестче для Ф1)
    AIR_WHEEL_Z = 6,
    GROUND_WHEEL_Z = 8,
    WHEEL_Z_SMOOTH = 0.8, -- Более резкая реакция подвески
}

-- --- Переменные состояния (Runtime Data) ---

State.Data = {
    engineRPM = 0,
    prevEngineRPM = 0,
    currentGear = 1,
    isEngineOn = false,
    
    speedMps = 0,        -- Скорость в м/с
    prevSpeedMps = 0,
    acceleration = 0,
    
    steerAngle = 0,      -- Угол поворота колес
    
    -- Состояние подвески колес
    wheelZ = {
        FR = 8,
        FL = -8,
        RL = 8,
        RR = -8
    },

    -- Флаги состояния игрока/машины
    inVehicle = false,
    isVehicleOnGround = false,
    accelState = false   -- Нажат ли газ
}

return State