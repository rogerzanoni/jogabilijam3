local Character = require 'character'
local sodapop = require "libs/sodapop/sodapop"
local steer = require 'steer'

Officer = Character:extend()

-- States
local IDLE = 'idle'
local MOVING = 'moving'
local LOADING = 'loading'
local ATTACKING = 'attacking'

local LOAD_FRAMES = 20
local ATTACK_FRAMES = 40

function Officer:new(x, y)
   Officer.super.new(self, x, y)
   self.state = IDLE
   self.target = nil
   self.damage = 30
   self.life = 100

   -- Motion
   self.velocity = vector(0, 0)
   self.max_velocity = 1.0

   -- Distances
   self.sight_distance = 200
   self.attack_distance = 20

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
         frameWidth=32, frameHeight=32, stopAtEnd=false, frames={ {1, 3, 7, 3, .1} } })

   self.sprite:addAnimation(LOADING,
       { image = love.graphics.newImage 'assets/images/officer-spritesheet.png',
         frameWidth=32, frameHeight=32, stopAtEnd=false, frames={ {1, 7, 7, 7, .1} } })

   self.sprite:addAnimation(ATTACKING,
       { image = love.graphics.newImage 'assets/images/officer-spritesheet.png',
         frameWidth=32, frameHeight=32, stopAtEnd=false, frames={ {1, 9, 7, 9, .1} } })
end

function Officer:update(dt)
   Officer.super.update(self, dt)
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

function Officer:changeState(state)
   self.sprite:switch(state)
   self.state = state
end

function Officer:look()
   self:seek_target()
   if not (self.target == nil) then
      print("[state] IDLE -> MOVING")
      self:changeState(MOVING)
      self.sprite.flipX = self.target.position.x < self.position.x
   end
end

function Officer:move()
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

function Officer:load()
   if self.loading_timer >= LOAD_FRAMES then
      self.loading_timer = 0
      print("[state] LOADING -> ATTACKING")
      self:changeState(ATTACKING)
   else
      self.loading_timer = self.loading_timer + 1
   end
end

function Officer:attack()
   if self.attacking_timer >= ATTACK_FRAMES then
      self.attacking_timer = 0
      self.target:receiveDamage(self.damage)
      print("[state] ATTACKING -> IDLE")
      self:changeState(IDLE)
   else
      self.attacking_timer = self.attacking_timer + 1
   end
end

function Officer:seek_target()
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


return Officer
