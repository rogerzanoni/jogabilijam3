
function manhattan(p, q)
   assert(#p == #q, 'vectors must have the same length')
   local s = 0
   for i in ipairs(p) do
      s = s + math.abs(p[i] - q[i])
   end
   return s
end

function key_to_joy(key)
    local map = {
        up = "dpup",
        down = "dpdown",
        left = "dpleft",
        right = "dpright",
        a = "x",
        s = "y",
        z = "a",
        x = "b",
    }
    return map[key]
end

function gamepadConnected()
   joysticks = love.joystick.getJoysticks()
   return #joysticks > 0
end

function math.Clamp(val, lower, upper)
    return math.max(lower, math.min(upper, val))
end
