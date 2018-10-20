local Timer = require "libs/hump/timer"
local Character = require "character"

Projectile = Object:extend()

function Projectile:new(size, ox, oy, dx, dy, duration, loyalty)
   self.loyalty = loyalty
   self.size = size
   self.pos = { ox, oy }
   self.dst = { dx, dy }
   Timer.tween(duration, self.pos, self.dst, "linear")
end

function Projectile:update(dt)
   Timer.update(dt)
end

function Projectile:draw()
   -- love.
   if self.loyalty == Character.LOYALTY_ENEMY then
      love.graphics.setColor(0, 0, 255)
   else
      love.graphics.setColor(255, 0 , 0)
   end

   love.graphics.setLineWidth(self.size)
   love.graphics.line(self.pos[1], self.pos[2],
                      self.dst[1], self.dst[2])
end

function Projectile:hasLanded()
   return math.ceil(self.pos[1]) == math.ceil(self.dst[1]) and math.ceil(self.pos[2]) == math.ceil(self.dst[2])
end

return Projectile

