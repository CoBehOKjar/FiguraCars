local state = require("state")

function pings.inputSync(f, b, l, r)
    state.Input.accelState = f
    state.Input.backState = b
    state.Input.leftState = l
    state.Input.rightState = r
end
