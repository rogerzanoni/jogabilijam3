require "assets"

Character = Object:extend()

Character.LOYALTY_NONE  = 'none'
Character.LOYALTY_USER  = 'user'
Character.LOYALTY_ENEMY = 'enemy'
Character.LOYALTY_ALLY  = 'ally'

function Character:new(x, y, life, damage)
   self.position = vector(x, y)
   self.life = life
   self.max_life = life
   self.damage = damage
   self.position = vector(x, y)
   self.loyalty = self.LOYALTY_USER
end

function Character:isDead()
   return self.life <= 0
end

function Character:isHurt()
   return self.life < self.max_life
end

function Character:isHealable()
   return true
end

function Character:clamp()
    self.position.x = math.Clamp(self.position.x, self.box_width / 2, CONF_SCREEN_WIDTH - self.box_width / 2)
    self.position.y = math.Clamp(self.position.y, self.box_height / 2, CONF_SCREEN_HEIGHT - self.box_height / 2)
end


function Character:changeState(state)
   print("[state] " .. self.state .. " -> " .. state)
   self.sprite:switch(state)
   self.state = state
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
   self.sprite:draw(ox, oy)

   -- Draw life bar
   if not self:isDead() then
      love.graphics.setColor(0, 0, 0)
      love.graphics.rectangle("fill", self.position.x - (self.box_width/2), self.position.y - (self.box_height/2) - 10, self.box_width, 5)
      love.graphics.setColor(0, 255, 0)
      love.graphics.rectangle("fill", self.position.x - (self.box_width/2), self.position.y - (self.box_height/2) - 10, self.box_width * (self.life/self.max_life), 5)
   end
end

return Character
