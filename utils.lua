
function manhattan(p, q)
   assert(#p == #q, 'vectors must have the same length')
   local s = 0
   for i in ipairs(p) do
      s = s + math.abs(p[i] - q[i])
   end
   return s
end

function key_to_joy(key)
   if key == "up" then
      return "dpup"
   elseif key == "down" then
      return "dpdown"
   elseif key == "left" then
      return "dpleft"
   elseif key == "right" then
      return "dpright"
   elseif key == "1" then
      return "a"
   elseif key == "2" then
      return "b"
   elseif key == "3" then
      return "x"
   elseif key == "4" then
      return "y"
   else
      return nil
   end
end

function gamepadConnected()
   joysticks = love.joystick.getJoysticks()
   return #joysticks > 0
end

function math.Clamp(val, lower, upper)
    return math.max(lower, math.min(upper, val))
end
