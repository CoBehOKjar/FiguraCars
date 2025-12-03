local State = {}


--*Objects
Driver = models.car.F1.Driver                                                   --?Driver model
DriverFP = models.car.F1.WorldRoot.DriverFP                                     --?Driver model for firs person render
F1 = models.car.F1.WorldRoot                                                    --?Car model
Tens = models.car.F1.WorldRoot.Car.Frame.SteeringWheel.SteeringWheelUITens      --?Speedometer tens display part
Units = models.car.F1.WorldRoot.Car.Frame.SteeringWheel.SteeringWheelUIUnits    --?Speedometer units display part
Gear = models.car.F1.WorldRoot.Car.Frame.SteeringWheel.SteeringWheelUIGear      --?Speedometer gear display part
RPM = models.car.F1.WorldRoot.Car.Frame.SteeringWheel.SteeringWheelUIRPM        --?Speedometer RPM display part

State.Objects = {
    --?Input keys
    ACKEY = keybinds:fromVanilla("key.forward"),
    BKKEY = keybinds:fromVanilla("key.back"),
    LFKEY = keybinds:fromVanilla("key.left"),
    RTKEY = keybinds:fromVanilla("key.right"),

    --?Animations path
    GAS = animations["car.F1"].Gas,
    REVERSE = animations["car.F1"].Reverse,
    STEERING = animations["car.F1"].Steering,
}


--*Const
State.Config = {
    --?Numbers UV coordinates for speedometer
    SPEED_UV = {
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

    --?RPM scale UV coordinates for speedometer
    RPM_UV = {
        vec(113/128,40/128),
        vec(113/128,41/128),
        vec(113/128,42/128),
        vec(113/128,43/128),
        vec(113/128,44/128),
        vec(113/128,45/128),
        vec(113/128,46/128),
        vec(113/128,47/128),
        vec(113/128,48/128),
        vec(113/128,49/128),
        vec(113/128,50/128)
    },

    --?Gears indicator UV coordinates for speedometer
    GEAR_UV = {
        vec(113/128,51/128),
        vec(113/128,52/128),
        vec(113/128,53/128),
        vec(113/128,54/128),
        vec(113/128,55/128),
        vec(113/128,56/128)
    },

    --.RPM const
    IDLE_RPM = 800,                     --?RPM when idle
    MAX_RPM = 12000,                    --?RPM up limit
    RPM_ACCEL_BASE_RATE = 250,          --?RPM acceleration speed
    RPM_DECEL_RATE = 0.15,              --?RPM deceleration speed
    RPM_TO_WHEEL_SPEED_FACTOR = 0.0005, --TODO добавить описание
    COASTING_WHEEL_FACTOR = 0.1,        --TODO добавить описание
    REVERSE_SLOWDOWN_FACTOR = 0.5,      --?Wheels animation speed multiplier when reversing
    
    --.Gear changing RPM
    SHIFT_UP_RPM = 11500,               --?Gear shift up RPM
    SHIFT_UP_TARGET_RPM = 7000,         --?RPM after gear shift up
    SHIFT_DOWN_BLIP_RPM = 9000,         --?Gas afted gear shift down
    gearShiftDownSpeed = {              --?Speed for gear shit down
        [1] = 0,
        [2] = 10,
        [3] = 20,
        [4] = 35,
        [5] = 50,
        [6] = 70
    },
    gearRatio = {                       --?Gear ratios
        [1] = 4.5,
        [2] = 3.2,
        [3] = 2.4,
        [4] = 1.8,
        [5] = 1.4,
        [6] = 1.1
    },

    --.Steering config
    STEERING_SMOOTHNESS = 0.1,          --?Smoothness for steering animation
    MAX_STEER_ANGLE = 18,               --?Max frames for one side
}


--*Runtime
State.Data = {
    --.Car states
    engineRPM = 0,          --?Current RPM
    prevEngineRPM = 0,      --?RPM in last tick
    currentGear = 1,        --?Current gear
    
    speedMps = 0,           --?Current speed in m|s or blocks per second
    prevSpeedMps = 0,       --?Speed in last tick
    acceleration = 0,       --?Current acceleration
    
    steerAngle = 0,         --?Current steer angle

    --.Driver states
    inVehicle = false,      --?Is player sit in wehicle
    wasInVehicle = false,   --?Is player sitting in wehicle on last tick
    isDriving = false       --?Is now pressed gas or back
}

State.Input = {
    --.Current keys pressed
    accelState = false, --?Froward  (W)
    backState = false,  --?Backward (S)
    leftState = false,  --?Left     (A)
    rightState = false  --?Right    (D)
}

State.Settings = {
    --.Any seetings for action wheel
    camHeight = -0.3,   --?Camera height in car
}

return State