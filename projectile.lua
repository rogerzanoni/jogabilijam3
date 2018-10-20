local Timer = require "libs/hump/timer"

Projectile = Object:extend()

function Projectile:new(ox, oy, dx, dy, duration)
   self.pos = { ox, oy }
   self.dst = { dx, dy }
   Timer.tween(duration, self.pos, self.dst, "linear")
end

function Projectile:update(dt)
   Timer.update(dt)
end

function Projectile:draw()
   -- love.
   love.graphics.setColor(255,127,0)
   love.graphics.setLineWidth(2)
   love.graphics.line(self.pos[1], self.pos[2],
                      self.pos[1]+2, self.pos[2])
end

function Projectile:hasLanded()
   return math.ceil(self.pos[1]) == math.ceil(self.dst[1]) and math.ceil(self.pos[2]) == math.ceil(self.dst[2])
end

return Projectile

