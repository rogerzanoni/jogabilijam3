local Character = require 'character'
local steer = require 'steer'

Gun = Character:extend()

-- States
local IDLE = 'idle'
local MOVING = 'moving'
local LOADING = 'loading'
local ATTACKING = 'attacking'

local LOAD_FRAMES = 20
local ATTACK_FRAMES = 40

function Gun:new(x, y)
   Gun.super.new(self, x, y)
   self.state = IDLE
   self.target = nil
   self.damage = 60
   self.max_life = 70
   self.life = self.max_life
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

   self.sprite:addAnimation(IDLE,
       { image = love.graphics.newImage 'assets/images/officer-spritesheet.png',
         frameWidth=32, frameHeight=32, stopAtEnd=false, frames={ {1, 1, 7, 1, .1} } })

   self.sprite:addAnimation(MOVING,
       { image = love.graphics.newImage 'assets/images/officer-spritesheet.png',
         frameWidth=32, frameHeight=32, stopAtEnd=false, frames={ {1, 25, 7, 25, .1} } })

   self.sprite:addAnimation(LOADING,
       { image = love.graphics.newImage 'assets/images/officer-spritesheet.png',
         frameWidth=32, frameHeight=32, stopAtEnd=false, frames={ {1, 27, 7, 27, .1} } })

   self.sprite:addAnimation(ATTACKING,
       { image = love.graphics.newImage 'assets/images/officer-spritesheet.png',
         frameWidth=32, frameHeight=32, stopAtEnd=false, frames={ {1, 26, 7, 26, .1} } })
end

function Gun:update(dt)
   Gun.super.update(self, dt)
   if self.state == IDLE then
      self:look()
   elseif self.state == MOVING then
      self:move()
   elseif self.state == LOADING then
      self:load()
   elseif self.state == ATTACKING then
      self:attack()
   end
end

function Gun:changeState(state)
   self.sprite:switch(state)
   self.state = state
end

function Gun:look()
   self:seek_target()
   if not (self.target == nil) then
      print("[state] IDLE -> MOVING")
      self:changeState(MOVING)
      self.sprite.flipX = self.target.position.x < self.position.x
   end
end

function Gun:move()
   if not (self.target==nil) then
      local distance = self.position:dist(self.target.position)
      if distance > self.attack_distance then
         local desired_velocity = steer.seek(self.position, self.target.position) * self.max_velocity
         local steering = desired_velocity - self.velocity
         self.velocity = self.velocity + steering
         self.position = self.position + self.velocity
      else
         print("[state] MOVING -> LOADING")
         self:changeState(LOADING)
      end
   end
end

function Gun:load()
   if self.loading_timer >= LOAD_FRAMES then
      self.loading_timer = 0
      print("[state] LOADING -> ATTACKING")
      self:changeState(ATTACKING)
   else
      self.loading_timer = self.loading_timer + 1
   end
end

function Gun:attack()
   if self.attacking_timer >= ATTACK_FRAMES then
      self.attacking_timer = 0
      self.target:receiveDamage(self.damage)
      print("[state] ATTACKING -> IDLE")
      self:changeState(IDLE)
   else
      self.attacking_timer = self.attacking_timer + 1
   end
end

function Gun:seek_target()
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


return Gun
