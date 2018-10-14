require "assets"

local Object = require "libs/classic/classic"

Character = Object:extend()

function Character:new(x, y)
   self.position = vector(x, y)
end

function Character:receiveDamage(damage)
   self.life = self.life - damage
end

function Character:isDead()
   return self.life <= 0
end

function Character:update(dt)
   if self.sprite == nil then
      return
   end
   self.sprite.x = self.position.x
   self.sprite.y = self.position.y
   self.sprite:update(dt)
end

function Character:draw(ox, oy)
   if self.sprite == nil then
      return
   end
   self.sprite.sx = settings:screenScaleFactor()
   self.sprite.sy = settings:screenScaleFactor()
   self.sprite:draw(ox, oy)
end

return Character
