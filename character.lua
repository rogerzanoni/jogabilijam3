require "assets"

Character = Object:extend()

Character.LOYALTY_NONE  = "none"
Character.LOYALTY_USER  = "user"
Character.LOYALTY_ENEMY = "enemy"
Character.LOYALTY_ALLY  = "ally"

Character.VANISH_TIME = 3

function Character:new(x, y, life, damage, loyalty)
   self.position = vector(x, y)
   self.life = life
   self.max_life = life
   self.damage = damage
   self.loyalty = loyalty
   self.box_height = 120
   self.box_width = 120
   self.dead_for = 0
end

function Character:isDead()
   return self.life <= 0
end

function Character:isGone()
   return self.dead_for >= self.VANISH_TIME
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
   if self.sprite.animations[state] ~= nil then
      self.sprite:switch(state)
   end
   self.state = state
end

function Character:update(dt)
   if self.sprite == nil then
      return
   end
   self.sprite.x = self.position.x
   self.sprite.y = self.position.y
   local polar = self.velocity:toPolar()
   if (polar.y ~= 0) then
      self.sprite.flipX = math.sin(polar.x) < 0
   end
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
      love.graphics.rectangle("fill", self.position.x - (self.box_width/2), self.position.y - (self.box_height/2), self.box_width, 5)
      love.graphics.setColor(0, 255, 0)
      love.graphics.rectangle("fill", self.position.x - (self.box_width/2), self.position.y - (self.box_height/2), self.box_width * (self.life/self.max_life), 5)
   end
end

function Character:getEnemiesList()
   if self.loyalty == self.LOYALTY_USER then
      return gameworld_officers
   elseif self.loyalty == self.LOYALTY_ENEMY then
      return gameworld_demonstrators
   end
end

function Character:getFriendsList()
   if self.loyalty == self.LOYALTY_USER then
      return gameworld_demonstrators
   elseif self.loyalty == self.LOYALTY_ENEMY then
      return gameworld_officers
   end

end

return Character
