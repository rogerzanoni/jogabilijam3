
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

function clamp(character)
    character.position.x = math.Clamp(character.position.x, character.box_width / 2, CONF_SCREEN_WIDTH - character.box_width / 2)
    character.position.y = math.Clamp(character.position.y, character.box_height / 2, CONF_SCREEN_HEIGHT - character.box_height / 2)
end

function math.Clamp(val, lower, upper)
    return math.max(lower, math.min(upper, val))
end
