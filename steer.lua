function seek(current_position, target_position)
   return (target_position - current_position):normalized()
end

function flee(current_position, menace_position)
   return - seek(current_position, menace_position)
end

function arrival(current_position, target_position, arrivalRadius)
    local distance = (target_position - current_position):dist()
    if (distance < arrivalRadius) then
        return distance / arrivalRadius
    else
        return 1
    end
end

function wander(current_position, current_velocity, wander_distance, wander_radius)
    local direction = current_velocity:normalized()
    local circle_center = current_position + direction * wander_distance

    local wander_angle = 2 * math.pi * math.random()

    local wander_position = vector(
        math.ceil(circle_center.x + wander_radius * math.cos(wander_angle)),
        math.ceil(circle_center.y + wander_radius * math.sin(wander_angle)))

    return wander_position
end

local steer = {}
steer.arrival = arrival
steer.flee = flee
steer.seek = seek
steer.wander = wander
return steer