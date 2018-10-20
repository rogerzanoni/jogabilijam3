local Character = require 'character'
local steer = require 'steer'

Gunner = Character:extend()

-- States
local STATE_IDLE = 'idle'
local STATE_MOVING = 'moving'
local STATE_LOADING = 'loading'
local STATE_ATTACKING = 'attacking'
local STATE_DEAD = 'dead'

local LOAD_FRAMES = 20
local ATTACK_FRAMES = 40

function Gunner:new(x, y, life, damage)
   Gunner.super.new(self, x, y, life, damage)
   self.state = STATE_IDLE
   self.target = nil
   self.box_height = 32
   self.box_width = 32

   -- Motion
   self.velocity = vector(0, 0)
   self.max_velocity = 0.8

   -- Distances
   self.sight_distance = 500
   self.attack_distance = 370

   -- Timers
   self.loading_timer = 0
   self.attacking_timer = 0

   -- sprite
   self.sprite = sodapop.newAnimatedSprite(x, y)

   self.sprite:addAnimation(STATE_IDLE,
       { image = love.graphics.newImage 'assets/images/gunner-spritesheet.png',
         frameWidth=115, frameHeight=115, stopAtEnd=false, frames={ {1, 1, 4, 1, .2} } })

   self.sprite:addAnimation(STATE_MOVING,
       { image = love.graphics.newImage 'assets/images/gunner-spritesheet.png',
         frameWidth=115, frameHeight=115, stopAtEnd=false, frames={ {1, 1, 4, 1, .2} } })

   self.sprite:addAnimation(STATE_LOADING,
       { image = love.graphics.newImage 'assets/images/gunner-spritesheet.png',
         frameWidth=115, frameHeight=115, stopAtEnd=false, frames={ {1, 1, 4, 1, .2} } })

   self.sprite:addAnimation(STATE_ATTACKING,
       { image = love.graphics.newImage 'assets/images/gunner-spritesheet.png',
         frameWidth=115, frameHeight=115, stopAtEnd=false, frames={ {1, 1, 4, 1, .2} } })

   self.sprite:addAnimation(STATE_DEAD,
       { image = love.graphics.newImage 'assets/images/gunner-spritesheet.png',
         frameWidth=115, frameHeight=115, stopAtEnd=false, frames={ {1, 1, 4, 1, .2} } })
end

function Gunner:update(dt)
   Gunner.super.update(self, dt)
   if self.state == STATE_IDLE then
      self:look()
   elseif self.state == STATE_MOVING then
      self:move()
   elseif self.state == STATE_LOADING then
      self:load()
   elseif self.state == STATE_ATTACKING then
      self:attack()
   end

   self:clamp()
end

function Character:receiveDamage(damage)
   self.life = math.max(0, self.life - damage)
   if self:isDead() then
      self:changeState(STATE_DEAD)
   end
end

function Gunner:look()
   self:seek_target()
   if not (self.target == nil) then
      self:changeState(STATE_MOVING)
      self.sprite.flipX = self.target.position.x < self.position.x
   end
end

function Gunner:move()
   self:seek_target()
   if not (self.target==nil) then
      local distance = self.position:dist(self.target.position)
      if distance > self.attack_distance then
         local desired_velocity = steer.seek(self.position, self.target.position) * self.max_velocity
         local steering = desired_velocity - self.velocity
         self.velocity = self.velocity + steering
         self.position = self.position + self.velocity

         local polar = self.velocity:toPolar()
         if (polar[1] ~= nil) then
            self.sprite.flipX = math.cos(polar[1]) >= 0
         end

      else
         self:changeState(STATE_LOADING)
      end
   end
end

function Gunner:load()
   if self.loading_timer >= LOAD_FRAMES then
      self.loading_timer = 0
      self:changeState(STATE_ATTACKING)
   else
      self.loading_timer = self.loading_timer + 1
   end
end

function Gunner:attack()
   self:seek_target()
   if self.target~=nil and self.attacking_timer >= ATTACK_FRAMES then
      self.attacking_timer = 0
      self:shoot()
      self.target:receiveDamage(self.damage)
      self:changeState(STATE_IDLE)
      soundManager:play("laser")
   else
      self.attacking_timer = self.attacking_timer + 1
   end
end

function Gunner:shoot()
   table.insert(gameworld_projectiles,
                Projectile(8,
                           self.position.x,
                           self.position.y,
                           self.target.position.x,
                           self.target.position.y,
                           0.2))
end

function Gunner:seek_target()
   self.target = nil
   local closer = self.sight_distance
   for i, dem in ipairs(gameworld_demonstrators) do
      local distance = self.position:dist(dem.position)
      if distance < closer and (not dem:isDead()) then
         closer = distance
         self.target = dem
         print("Target found!" .. distance)
      end
   end
end


return Gunner
