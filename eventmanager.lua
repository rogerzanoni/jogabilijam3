EventManager = Object:extend()

local Timer = require 'libs/knife/knife/timer'

function EventManager:new(eventScript)
   self.eventScript = eventScript
end

function EventManager:init()
   for i, event in ipairs(self.eventScript) do
       Timer.after(event.time,  function() table.insert(gameworld_officers, event.unit(event.x, event.y, event.life, event.damage, Character.LOYALTY_ENEMY)) end)
   end
end

function EventManager:update(dt)
    Timer.update(dt)
end

return EventManager
