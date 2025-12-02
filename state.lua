local State = {}

-- --- Константы настройки (Config) ---
Driver = models.car.F1.Driver
F1 = models.car.F1.WorldRoot
Tens = models.car.F1.WorldRoot.Car.Frame.SteeringWheel.SteeringWheelUITens
Units = models.car.F1.WorldRoot.Car.Frame.SteeringWheel.SteeringWheelUIUnits

-- Настройки двигателя и трансмиссии
State.Config = {
    ACKEY = keybinds:fromVanilla("key.forward"),
    BKKEY = keybinds:fromVanilla("key.back"),
    LFKEY = keybinds:fromVanilla("key.left"),
    RTKEY = keybinds:fromVanilla("key.right"),

    GAS = animations["car.F1"].Gas,
    REVERSE = animations["car.F1"].Reverse,
    STEERING = animations["car.F1"].Steering,

    SPEED_NUMS = {
    vec(123/128,40/128),
    vec(123/128,45/128),
    vec(123/128,50/128),
    vec(123/128,55/128),
    vec(123/128,60/128),
    vec(123/128,65/128),
    vec(123/128,70/128),
    vec(123/128,75/128),
    vec(123/128,80/128),
    vec(123/128,85/128)
    },

    IDLE_RPM = 800,               -- Холостые обороты
    MAX_RPM = 12000,              -- Максимальные обороты (повышено для Ф1)
    RPM_ACCEL_BASE_RATE = 250,    -- Скорость набора оборотов
    RPM_DECEL_RATE = 0.15,        -- Скорость сброса оборотов
    RPM_TO_WHEEL_SPEED_FACTOR = 0.0005,
    COASTING_WHEEL_FACTOR = 0.1,
    REVERSE_SLOWDOWN_FACTOR = 0.5,
    
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
        [6] = 70
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
    STEERING_SMOOTHNESS = 0.1,
    STEERING_SENSITIVITY = 45,
    MAX_STEER_ANGLE = 45,
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

    -- Флаги состояния игрока/машины
    inVehicle = false,
    isVehicleOnGround = false,

    accelState = false,
    backState = false,
    leftState = false,
    rightState = false
}

State.DriverPose = {

}

return State